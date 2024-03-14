module ALU #(
    parameter DATA_W = 32
)
(
    input                       i_clk,   // clock
    input                       i_rst_n, // reset

    input                       i_valid, // input valid signal
    input [DATA_W - 1 : 0]      i_A,     // input operand A
    input [DATA_W - 1 : 0]      i_B,     // input operand B
    input [         2 : 0]      i_inst,  // instruction

    output [2*DATA_W - 1 : 0]   o_data,  // output value
    output                      o_done   // output valid signal
);
// Do not Modify the above part !!!

// Parameters
    // ======== choose your FSM style ==========
    // 1. FSM based on operation cycles
    parameter S_IDLE           = 2'd0;
    parameter S_ONE_CYCLE_OP   = 2'd1;
    parameter S_MULTI_CYCLE_OP = 2'd2;
    // 2. FSM based on operation modes
    // parameter S_IDLE = 4'd0;
    // parameter S_ADD  = 4'd1;
    // parameter S_SUB  = 4'd2;
    // parameter S_AND  = 4'd3;
    // parameter S_OR   = 4'd4;
    // parameter S_SLT  = 4'd5;
    // parameter S_SRA  = 4'd6;
    // parameter S_MUL  = 4'd7;
    // parameter S_DIV  = 4'd8;
    // parameter S_OUT  = 4'd9;

// Wires & Regs
    // Todo
    // state
    reg  [         1: 0] state, state_nxt; // remember to expand the bit width if you want to add more states!
    // load input
    reg  [  DATA_W-1: 0] operand_a, operand_a_nxt;
    reg  [  DATA_W-1: 0] operand_b, operand_b_nxt;
    reg  [         2: 0] inst, inst_nxt;
    reg  [         2*DATA_W-1:0] shift, shift_nxt;
    reg  [          4:0] counter, counter_nxt;
    reg  [         2*DATA_W-1:0] outcheck, outcheck_nxt;
    reg  output_done, output_done_nxt;
// Wire Assignments
    // Todo
    assign o_data = shift;
    assign o_done = output_done;
// Always Combination
    // load input
    always @(*) begin
        if (i_valid) begin
            operand_a_nxt = i_A;
            operand_b_nxt = i_B;
            inst_nxt      = i_inst;
        end
        else begin
            operand_a_nxt = operand_a;
            operand_b_nxt = operand_b;
            inst_nxt      = inst;
        end
    end
    // Todo: FSM
    always @(*) begin
        case(state)
            S_IDLE           :begin
                if(i_valid) begin
                    if(i_inst==3'd6 |i_inst==3'd7)begin
                        state_nxt <= S_MULTI_CYCLE_OP;
                    end
                    else begin
                        state_nxt <= S_ONE_CYCLE_OP;
                    end
                end
                else begin
                    state_nxt <= S_IDLE;
                end
            end
            S_ONE_CYCLE_OP   :begin
                state_nxt <= S_IDLE;
            end
            S_MULTI_CYCLE_OP :begin
                state_nxt <= (counter == 5'd31)? S_IDLE : S_MULTI_CYCLE_OP;
            end
            default : state_nxt <= state;
        endcase
    end
    // Todo: Counter
    
    always @(posedge i_clk)begin
        case(state)
            S_MULTI_CYCLE_OP:begin
                    counter_nxt  = counter +5'd1 ;   
            end
            default:begin
                counter_nxt = 5'b00000;
            end
        endcase
    end
    // Todo: ALU output
    always @(*)begin
        shift_nxt[2*DATA_W-1:0]=0;
        case(state)
            S_ONE_CYCLE_OP:begin
                case(inst)
                    3'd0:begin
                        outcheck[DATA_W-1:0] = operand_a + operand_b;
                        if (operand_a[DATA_W-1]^operand_b[DATA_W-1])begin
                            shift_nxt[DATA_W-1:0] = outcheck[DATA_W-1:0];
                        end
                        else begin
                            if (outcheck[DATA_W-1] == operand_a[DATA_W-1])begin
                                shift_nxt[DATA_W-1:0] = outcheck[DATA_W-1:0];
                            end
                            else begin
                                case(operand_a[DATA_W-1])
                                    0:shift_nxt[DATA_W-1:0] = 32'h7fffffff;
                                    1: shift_nxt[DATA_W-1:0] = 32'h80000000;
                                endcase 
                            end
                        end
                    end
                    3'd1:begin
                        outcheck[DATA_W-1:0] = operand_a - operand_b;
                            if (operand_a[DATA_W-1] ==operand_b[DATA_W-1])begin
                                shift_nxt[DATA_W-1:0] = outcheck[DATA_W-1:0];
                            end
                            else begin
                                if(operand_a[DATA_W-1]^outcheck[DATA_W-1])begin
                                case(outcheck[DATA_W-1])
                                    0:shift_nxt[DATA_W-1:0]=32'h80000000;
                                    1:shift_nxt[DATA_W-1:0] = 32'h7fffffff;
                                endcase 
                                end
                                else begin
                                    shift_nxt[DATA_W-1:0] = outcheck[DATA_W-1:0];
                                end
                            end
                    end
                    3'd2:begin
                        shift_nxt[DATA_W-1:0] = operand_a[DATA_W-1:0] & operand_b[DATA_W-1:0];
                    end
                    3'd3:begin
                        shift_nxt[DATA_W-1:0] = operand_a[DATA_W-1:0] | operand_b[DATA_W-1:0];
                    end
                    3'd4:begin
                        if(operand_a[DATA_W-1]==1 && operand_b[DATA_W-1]==0)begin
                            shift_nxt[DATA_W-1:0] = 1;
                        end
                        else if(operand_a[DATA_W-1]==0 && operand_b[DATA_W-1]==1)begin
                            shift_nxt[DATA_W-1:0]  = 0;
                        end
                        else begin
                            outcheck_nxt[DATA_W-1:0] = operand_a[DATA_W-1:0] -operand_b[DATA_W-1:0];
                            if  (outcheck_nxt[DATA_W-1]==1)begin
                              shift_nxt[DATA_W-1:0] =1;
                            end
                            else begin
                              shift_nxt[DATA_W-1:0] =0;
                            end
                        end
                    end
                    3'd5:begin
                      shift_nxt[DATA_W-1:0] = $signed(operand_a[DATA_W-1:0])>>>operand_b[DATA_W-1:0];
                    end
                    default: begin
                      shift_nxt[2*DATA_W-1:0] = 0;
                    end
                endcase 
            end
            S_MULTI_CYCLE_OP:begin
                case(inst)
                    3'd6:begin
                        if(counter==5'b00000)begin
                          shift_nxt[DATA_W-1:0] =operand_a[DATA_W-1:0];
                          if(shift_nxt[0]==0)begin
                            shift_nxt[2*DATA_W-1:0] = shift_nxt[2*DATA_W-1:0]>>1;
                          end
                          else begin
                            shift_nxt[2*DATA_W-1:0] = shift_nxt[2*DATA_W-1:0]>>1;
                            shift_nxt[2*DATA_W-1:DATA_W-1] = shift_nxt[2*DATA_W-1:DATA_W-1]+operand_b[DATA_W-1:0];
                          end
                        end
                        else begin
                            if(shift[0]==0)begin
                                shift_nxt[2*DATA_W-1:0] = shift[2*DATA_W-1:0]>>1;
                            end
                            else begin
                                shift_nxt[2*DATA_W-1:0] = shift[2*DATA_W-1:0];
                                shift_nxt[2*DATA_W-1:0] = shift_nxt[2*DATA_W-1:0]>>1; 
                                shift_nxt[2*DATA_W-1:DATA_W-1] = shift_nxt[2*DATA_W-1:DATA_W-1]+operand_b[DATA_W-1:0];
                            end
                        end
                    end
                    3'd7:begin
                        
                        if(counter ==0)begin
                          shift_nxt[2*DATA_W-1:0] = operand_a[DATA_W-1:0]<<1;
                          if(shift_nxt[2*DATA_W-1:DATA_W]>=operand_b[DATA_W-1:0])begin
                            shift_nxt[2*DATA_W-1:DATA_W] = shift_nxt[2*DATA_W-1:DATA_W] - operand_b[DATA_W-1:0];
                            shift_nxt[2*DATA_W-1:0] = shift_nxt[2*DATA_W-1:0]<<1;
                            shift_nxt[0]=1;
                          end
                          else begin
                            shift_nxt[2*DATA_W-1:0] = shift_nxt[2*DATA_W-1:0]<<1;
                          end
                        end
                        else if (counter < DATA_W-1 && counter>0 )begin
                            if(shift[2*DATA_W-1:DATA_W]<operand_b[DATA_W-1:0])begin
                              shift_nxt[2*DATA_W-1:0] = shift[2*DATA_W-1:0]<<1;
                            end
                            else begin  
                              shift_nxt[2*DATA_W-1:0] = shift[2*DATA_W-1:0];
                              shift_nxt[2*DATA_W-1:DATA_W] = shift[2*DATA_W-1:DATA_W] - operand_b[DATA_W-1:0];
                              shift_nxt[2*DATA_W-1:0] = shift_nxt[2*DATA_W-1:0]<<1;
                              shift_nxt[0]=1;
                            end
                        end
                        else begin
                            if (shift[2*DATA_W-1:DATA_W]<operand_b[DATA_W-1:0])begin
                                shift_nxt[2*DATA_W-1:0]=shift[2*DATA_W-1:0];
                                shift_nxt[DATA_W-1:0] = shift[DATA_W-1:0]<<1;
                            end
                            else begin
                                shift_nxt[2*DATA_W-1:0] = shift[2*DATA_W-1:0];
                                shift_nxt[2*DATA_W-1:DATA_W] =shift[2*DATA_W-1:DATA_W] - operand_b[DATA_W-1:0];
                                shift_nxt[DATA_W-1:0] = shift_nxt[DATA_W-1:0]<<1;
                                shift_nxt[0]=1;
                            end
                        end
                    end
                    default: shift_nxt[2*DATA_W-1:0] = 0;
                endcase
            end
            default: shift_nxt[2*DATA_W-1:0]=0;
        endcase 



    end
    // Todo: output valid signal
    always @(*)begin
        case(state)
            S_IDLE :output_done_nxt =0;
            S_ONE_CYCLE_OP:output_done_nxt =1;
            S_MULTI_CYCLE_OP:begin
                if (counter == 5'd31)begin
                    output_done_nxt =1;
                end
                else begin
                    output_done_nxt =0;
                end
            end
            default: output_done_nxt=0;
        endcase
    end
    // Todo: Sequential always block
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state       <= S_IDLE;
            operand_a   <= 0;
            operand_b   <= 0;
            inst        <= 0;
            output_done <=0;
            counter     <=0;
            shift <=0;
        end
        else begin
            state       <= state_nxt;
            operand_a   <= operand_a_nxt;
            operand_b   <= operand_b_nxt;
            inst        <= inst_nxt;
            counter <= counter_nxt;
            output_done <=output_done_nxt;
            shift <= shift_nxt;
        end
    end

endmodule