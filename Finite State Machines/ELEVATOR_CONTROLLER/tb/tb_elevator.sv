`timescale 1ns/1ps

module tb_elevator;

    logic rst;
    logic clk;

    logic req0, req1, req2;
    logic motor_up, motor_down, door_open;
    logic [1:0] current_floor;

    elevator_controller dut(
        .clk(clk),
        .rst(rst),
        .req0(req0),
        .req1(req1),
        .req2(req2),
        .motor_up(motor_up),
        .motor_down(motor_down),
        .door_open(door_open),
        .current_floor(current_floor)
    );

    // 100 MHz equivalent (10 ns period)
    always #5 clk = ~clk;

    // -----------------------------
    // Small helper tasks (college-level)
    // -----------------------------
    task automatic wait_cycles(input int unsigned n);
        repeat (n) @(posedge clk);
    endtask

    task automatic apply_reset(input int unsigned cycles = 2);
        rst  = 1'b1;
        req0 = 1'b0;
        req1 = 1'b0;
        req2 = 1'b0;
        wait_cycles(cycles);
        rst = 1'b0;
        @(posedge clk);
    endtask

    task automatic pulse_request(input int unsigned floor, input int unsigned hold_cycles = 1);
        // drive one-hot request for N cycles
        req0 = (floor == 0);
        req1 = (floor == 1);
        req2 = (floor == 2);
        wait_cycles(hold_cycles);
        req0 = 1'b0;
        req1 = 1'b0;
        req2 = 1'b0;
    endtask

    task automatic drive_requests(input logic r0, input logic r1, input logic r2, input int unsigned hold_cycles = 1);
        // directly drive inputs (useful for priority/invalid combos)
        req0 = r0;
        req1 = r1;
        req2 = r2;
        wait_cycles(hold_cycles);
        req0 = 1'b0;
        req1 = 1'b0;
        req2 = 1'b0;
    endtask

    task automatic wait_for_door_open(output bit seen, input int unsigned timeout_cycles = 25);
        int unsigned i;
        seen = 1'b0;
        begin : wait_loop
            for (i = 0; i < timeout_cycles; i++) begin
                @(posedge clk);
                if (door_open === 1'b1) begin
                    seen = 1'b1;
                    disable wait_loop;
                end
            end
        end
        if (!seen) $display("[%0t] TIMEOUT: door_open never asserted within %0d cycles", $time, timeout_cycles);
    endtask

    task automatic request_combo_until_door(
        input logic r0,
        input logic r1,
        input logic r2,
        input int unsigned timeout_cycles = 50
    );
        // This DUT treats requests as level-sensitive; keep them asserted until serviced.
        bit seen;
        int expected_floor;

        // same priority as DUT target_floor logic (req2 > req1 > req0)
        if (r2) expected_floor = 2;
        else if (r1) expected_floor = 1;
        else if (r0) expected_floor = 0;
        else expected_floor = int'(current_floor);

        req0 = r0;
        req1 = r1;
        req2 = r2;

        wait_for_door_open(seen, timeout_cycles);
        if (seen) begin
            if (^current_floor === 1'bx) begin
                $display("[%0t] ERROR: door_open seen but current_floor is X/Z", $time);
            end
            else if (int'(current_floor) != expected_floor) begin
                $display("[%0t] ERROR: door opened at floor %0d, expected %0d (req=%0b%0b%0b)",
                         $time, int'(current_floor), expected_floor, r2, r1, r0);
            end
        end

        req0 = 1'b0;
        req1 = 1'b0;
        req2 = 1'b0;
    endtask

    task automatic request_floor_until_door(input int unsigned floor, input int unsigned timeout_cycles = 50);
        request_combo_until_door((floor == 0), (floor == 1), (floor == 2), timeout_cycles);
    endtask

    // -----------------------------
    // Debugging / checks
    // -----------------------------
    int unsigned cycle;
    logic [1:0] last_floor;
    logic last_motor_up;
    logic last_motor_down;

    function automatic string b1(input logic v);
        if (v === 1'b0) b1 = "0";
        else if (v === 1'b1) b1 = "1";
        else b1 = "X";
    endfunction

    initial begin
        $timeformat(-9, 0, " ns", 8);
        $display("=== Elevator TB start ===");
        $display("Signals: req0/req1/req2 | floor | up/down/door");

        // Wave dump (Icarus/GTKWave friendly)
        $dumpfile("tb_elevator.vcd");
        $dumpvars(0, tb_elevator);

        clk = 1'b0;
        rst = 1'b0;
        req0 = 1'b0;
        req1 = 1'b0;
        req2 = 1'b0;

        cycle = 0;
        last_floor = '0;
        last_motor_up = 1'b0;
        last_motor_down = 1'b0;

        apply_reset(2);

        // ---- Exercise each input individually ----
        $display("\n[%0t] Test 1: Request floor 2", $time);
        request_floor_until_door(2, 50);
        wait_cycles(3);

        $display("\n[%0t] Test 2: Request floor 0", $time);
        request_floor_until_door(0, 50);
        wait_cycles(3);

        $display("\n[%0t] Test 3: Request floor 1 (hold for 2 cycles)", $time);
        request_floor_until_door(1, 50);
        wait_cycles(3);

        // ---- Priority / multiple inputs ----
        $display("\n[%0t] Test 4: Simultaneous req0+req2 (expect req2 priority if implemented)", $time);
        request_combo_until_door(1'b1, 1'b0, 1'b1, 50);
        wait_cycles(3);

        $display("\n[%0t] Test 5: All requests high for 2 cycles (stress)", $time);
        request_combo_until_door(1'b1, 1'b1, 1'b1, 50);
        wait_cycles(5);

        $display("\n=== TB done ===");
        $finish;
    end

    // Cycle-by-cycle debug print
    always @(posedge clk) begin
        cycle++;
        if (rst) begin
            $display("[%0t] C%0d  rst=1  req=%s%s%s  floor=%0d  up=%s down=%s door=%s",
                     $time, cycle, b1(req2), b1(req1), b1(req0), current_floor, b1(motor_up), b1(motor_down), b1(door_open));
            last_floor <= current_floor;
            last_motor_up <= 1'b0;
            last_motor_down <= 1'b0;
        end
        else begin
            int delta;
            $display("[%0t] C%0d  rst=0  req=%s%s%s  floor=%0d  up=%s down=%s door=%s",
                     $time, cycle, b1(req2), b1(req1), b1(req0), current_floor, b1(motor_up), b1(motor_down), b1(door_open));

            // Basic sanity checks (keep simple / educational)
            if ((motor_up === 1'b1) && (motor_down === 1'b1)) begin
                $display("[%0t] ERROR: motor_up and motor_down both asserted", $time);
            end

            if (^current_floor === 1'bx) begin
                $display("[%0t] ERROR: current_floor is X/Z", $time);
            end
            else if (current_floor > 2) begin
                $display("[%0t] ERROR: current_floor out of range (0-2): %0d", $time, current_floor);
            end

            // Movement consistency check (1-cycle delayed): floor updates on the clock edge
            // based on the *previous* cycle's movement command/state.
            if (^last_floor !== 1'bx && ^current_floor !== 1'bx) begin
                delta = int'(current_floor) - int'(last_floor);

                if ((last_motor_up === 1'b1) && (last_motor_down !== 1'b1)) begin
                    if (int'(last_floor) < 2) begin
                        if (delta != 1) $display("[%0t] WARN: expected floor +1 (last=%0d now=%0d)", $time, last_floor, current_floor);
                    end
                    else begin
                        if (delta != 0) $display("[%0t] WARN: expected floor hold at top (last=%0d now=%0d)", $time, last_floor, current_floor);
                    end
                end

                if ((last_motor_down === 1'b1) && (last_motor_up !== 1'b1)) begin
                    if (int'(last_floor) > 0) begin
                        if (delta != -1) $display("[%0t] WARN: expected floor -1 (last=%0d now=%0d)", $time, last_floor, current_floor);
                    end
                    else begin
                        if (delta != 0) $display("[%0t] WARN: expected floor hold at bottom (last=%0d now=%0d)", $time, last_floor, current_floor);
                    end
                end
            end

            last_motor_up <= motor_up;
            last_motor_down <= motor_down;
            last_floor <= current_floor;
        end
    end

endmodule