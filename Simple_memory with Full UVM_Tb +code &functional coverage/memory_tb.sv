package pack1;

import uvm_pkg::*;
`include "uvm_macros.svh"

// Sequence_item
///////////////////////////////////
class my_sequence_item extends uvm_sequence_item;
  
  `uvm_object_utils(my_sequence_item)

  rand logic [31:0] Data_in;
  rand logic [3:0] Address;
  rand logic write_En,read_En,rst;
  logic [31:0] Data_out;

  // constraint constr1{ unique {write_En,read_En};}
  
  function new(string name="my_sequence_item");
    super.new(name);
  endfunction

  function void print ();
    $display("time=%0t Data_in=%h Address=%h write_En=%b read_En=%b rst=%b Data_out=%h",
      ($time-11),Data_in,Address,write_En,read_En,rst,Data_out); //hacking
  endfunction

endclass



//my_sequence
class my_sequence extends uvm_sequence #(my_sequence_item);
  `uvm_object_utils(my_sequence)

  //here we instantiate seq_item
  my_sequence_item seq_item_inst;

  function new(string name ="my_sequence");
    super.new(name);
  endfunction

  task pre_body;
    seq_item_inst=my_sequence_item::type_id::create("seq_item_inst");
  endtask

  task body;
    logic [3:0] random_address;
    //read after write with rst in between
    start_item(seq_item_inst);
    assert (seq_item_inst.randomize() with {rst==0;Data_in==32'h00000;read_En!=write_En;});
    finish_item(seq_item_inst);

    for (int i = 0; i <40; i++) begin
      random_address=$random();
      start_item(seq_item_inst);
      assert (seq_item_inst.randomize() with {rst==1;write_En==1; read_En==0; Address==random_address;});
      finish_item(seq_item_inst);

      start_item(seq_item_inst);
      assert (seq_item_inst.randomize() with {rst==1;write_En==0;read_En==1;Address==random_address;});
      finish_item(seq_item_inst);
    end

    for (int i = 0; i < 16; i++) begin
      start_item(seq_item_inst);
      assert (seq_item_inst.randomize() with {rst==1;write_En==1;read_En==0;Address==i;});
      finish_item(seq_item_inst);

      start_item(seq_item_inst);
      assert (seq_item_inst.randomize() with {rst==1;write_En==0;read_En==1;Address==i;});
      finish_item(seq_item_inst);
    end

    //code coverage clauser
    start_item(seq_item_inst);
    assert (seq_item_inst.randomize() with {rst==0;read_En==0;write_En==0;Data_in==32'h00000;});
    finish_item(seq_item_inst);

    start_item(seq_item_inst);
    assert (seq_item_inst.randomize() with {rst==0;read_En==0;write_En==1;Data_in==32'h111111;});
    finish_item(seq_item_inst);

    start_item(seq_item_inst);
    assert (seq_item_inst.randomize() with {rst==0;read_En==1;write_En==0;Data_in==32'h111111;});
    finish_item(seq_item_inst);

    start_item(seq_item_inst);
    assert (seq_item_inst.randomize() with {rst==0;write_En==1;read_En==1;Data_in==32'h00000;});
    finish_item(seq_item_inst);

    start_item(seq_item_inst);
    assert (seq_item_inst.randomize() with {rst==1;read_En==0;write_En==0;Data_in==32'h111111;});
    finish_item(seq_item_inst);

    start_item(seq_item_inst);
    assert (seq_item_inst.randomize() with {rst==1;read_En==1;write_En==1;Data_in==32'h111111;});
    finish_item(seq_item_inst);

  endtask


endclass




//my_driver
/////////////////////////////
class my_driver extends uvm_driver #(my_sequence_item);
    my_sequence_item seq_item_inst;
    virtual intf driver_virtual;

  
  `uvm_component_utils(my_driver)
  
  function new(string name="my_driver" ,uvm_component parent =null);
    super.new(name,parent);
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    // $display("build_driver");
    seq_item_inst=my_sequence_item::type_id::create("seq_item_inst");
    if(!uvm_config_db #(virtual intf) ::get (this,"","my_vif",driver_virtual))
      `uvm_fatal(get_full_name(),"Error!")
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      seq_item_port.get_next_item(seq_item_inst);
      @(negedge driver_virtual.clk);
      driver_virtual.Data_in<=seq_item_inst.Data_in;
      driver_virtual.Address<=seq_item_inst.Address;
      driver_virtual.write_En<=seq_item_inst.write_En;
      driver_virtual.read_En<=seq_item_inst.read_En;
      driver_virtual.rst<=seq_item_inst.rst;
      #1 seq_item_port.item_done();
    end

  endtask 
    
    function void connect_phase (uvm_phase phase);
   	  super.connect_phase(phase);
      // $display("connect_driver");
    endfunction
    
  
endclass





//my_monitor
///////////////////////////////////////////////
class my_monitor extends uvm_monitor;
  my_sequence_item seq_item_inst;
  virtual intf monitor_virtual;
  `uvm_component_utils(my_monitor)
  
  uvm_analysis_port #(my_sequence_item) m_analysis_port;
  
  function new(string name="my_monitor" ,uvm_component parent =null);
    super.new(name,parent);
  endfunction  
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    // $display("build_monitor");
    seq_item_inst=my_sequence_item::type_id::create("seq_item_inst");
    m_analysis_port=new("m_analysis_port",this);
     if(!uvm_config_db #(virtual intf) ::get (this,"","my_vif",monitor_virtual))
      `uvm_fatal(get_full_name(),"Error!")
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      @(negedge monitor_virtual.clk);
      seq_item_inst.Data_in<=monitor_virtual.Data_in;
      seq_item_inst.Address<=monitor_virtual.Address;
      seq_item_inst.write_En<=monitor_virtual.write_En;
      seq_item_inst.read_En<=monitor_virtual.read_En;
      seq_item_inst.rst<=monitor_virtual.rst;
      seq_item_inst.Data_out<=monitor_virtual.Data_out;

      m_analysis_port.write(seq_item_inst); //hereeeeeeeeeeeeeeeeeeee
    end
  endtask


    function void connect_phase (uvm_phase phase);
   	  super.connect_phase(phase);
      // $display("connect_monitor");
    endfunction
endclass





//my_sequencer
//////////////////////////////////////////////
class my_sequencer extends uvm_sequencer #(my_sequence_item);  
    `uvm_component_utils(my_sequencer)
  
  function new(string name="my_sequencer" ,uvm_component parent =null);
    super.new(name,parent);
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    // $display("build_sequencer");

  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask 
    
    function void connect_phase (uvm_phase phase);
   	  super.connect_phase(phase);
      // $display("connect_sequencer");
    endfunction
endclass





//my_agent
///////////////////////////////////////////
class my_agent extends uvm_agent;
  my_sequencer sequencer;
  my_driver driver;
  my_monitor monitor;

  virtual intf config_virtual;
  virtual intf local_virtual;
  uvm_analysis_port #(my_sequence_item) m_analysis_port;

    `uvm_component_utils(my_agent)
  
  function new(string name="my_agent" ,uvm_component parent =null);
    super.new(name,parent);
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    // $display("build_agent");
    sequencer=my_sequencer::type_id::create("sequencer",this);
    driver=my_driver::type_id::create("driver",this);
    monitor=my_monitor::type_id::create("monitor",this);
    m_analysis_port=new("m_analysis_port",this);
     if(!uvm_config_db #(virtual intf) ::get (this,"","my_vif",config_virtual))
      `uvm_fatal(get_full_name(),"Error!")
    local_virtual=config_virtual;
    uvm_config_db #(virtual intf) ::set (this,"driver","my_vif",local_virtual);
    uvm_config_db #(virtual intf) ::set (this,"monitor","my_vif",local_virtual);
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask 
    
    function void connect_phase (uvm_phase phase);
   	  super.connect_phase(phase);
      // $display("connect_agent");
      monitor.m_analysis_port.connect(m_analysis_port);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
endclass




//my_scoreboard
///////////////////////////////////////////////////////////
class my_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(my_scoreboard)

    uvm_analysis_export #(my_sequence_item) m_analysis_export;
    uvm_tlm_analysis_fifo #(my_sequence_item) m_analysis_fifo;

    my_sequence_item seq_item_inst;
    my_sequence_item seq_item_inst_ex;

  function new(string name="my_scoreboard" ,uvm_component parent =null);
    super.new(name,parent);
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    // $display("build_score_board");
    m_analysis_export=new("m_analysis_export",this);
    m_analysis_fifo=new("m_analysis_fifo",this);
    seq_item_inst=my_sequence_item::type_id::create("seq_item_inst");
    seq_item_inst_ex=my_sequence_item::type_id::create("seq_item_inst_ex");

  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      m_analysis_fifo.get_peek_export.get(seq_item_inst);
      #1 seq_item_inst.print();
    end
  endtask 
    
    function void connect_phase (uvm_phase phase);
   	  super.connect_phase(phase);
       // $display("connect_score_board");
       m_analysis_export.connect(m_analysis_fifo.analysis_export);
    endfunction
  
endclass




//my_subscriber
///////////////////////////////////////////
class my_subscriber extends uvm_subscriber #(my_sequence_item);
    `uvm_component_utils(my_subscriber)

    my_sequence_item seq_item_inst;

    covergroup cov_inst();
      coverpoint seq_item_inst.rst {
        bins bin_1 []={0,1};
        bins bin_2 =(0=>1); 
        bins bin_3 =(1=>0); 
      }
      coverpoint seq_item_inst.Address;
      cross1 :cross seq_item_inst.write_En,seq_item_inst.read_En,seq_item_inst.rst;
      
    endgroup
  
  function new(string name="my_subscriber" ,uvm_component parent =null);
    super.new(name,parent);
    cov_inst=new();
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    // $display("build_subscriber");
    seq_item_inst=my_sequence_item::type_id::create("seq_item_inst");
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask 
    
    function void connect_phase (uvm_phase phase);
   	  super.connect_phase(phase);
      // $display("connect_subscriber");
    endfunction
   function void write (my_sequence_item t);
     seq_item_inst=t;
     cov_inst.sample();
   endfunction
  
endclass





//my_env
///////////////////////////////////////////
class my_env extends uvm_env;
  my_agent agent;
  my_scoreboard scoreboard;
  my_subscriber subscriber;
  virtual intf config_virtual;
  virtual intf local_virtual;
  
    `uvm_component_utils(my_env)
  
  function new(string name="my_env" ,uvm_component parent =null);
    super.new(name,parent);
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    // $display("build_env");
    agent=my_agent::type_id::create("agent",this);
    scoreboard=my_scoreboard::type_id::create("scoreboard",this);
    subscriber=my_subscriber::type_id::create("subscriber",this);
     if(!uvm_config_db #(virtual intf) ::get (this,"","my_vif",config_virtual))
      `uvm_fatal(get_full_name(),"Error!")
    local_virtual=config_virtual;
    uvm_config_db #(virtual intf) ::set (this,"agent","my_vif",local_virtual);

  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask 
    
    function void connect_phase (uvm_phase phase);
   	  super.connect_phase(phase);
      // $display("connect_env");
      agent.m_analysis_port.connect(scoreboard.m_analysis_export);
      agent.m_analysis_port.connect(subscriber.analysis_export);
      
    endfunction
  
endclass





//my_test
/////////////////////////////////////////////////
class my_test extends uvm_test;
  my_env env;
  my_sequence sequence_inst;
  virtual intf config_virtual;
  virtual intf local_virtual;

    `uvm_component_utils(my_test)
  
  function new(string name="my_test" ,uvm_component parent =null);
    super.new(name,parent);
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    // $display("build_Test_GAMEDDDDDDDDDDDDDDDDDDDDDDDDDDDDD");

    env=my_env::type_id::create("env",this);
    sequence_inst=my_sequence::type_id::create("sequence_inst");

    if(!uvm_config_db #(virtual intf) ::get (this,"","my_vif",config_virtual))
      `uvm_fatal(get_full_name(),"Error!")
    local_virtual=config_virtual;
    uvm_config_db #(virtual intf) ::set (this,"env","my_vif",local_virtual);
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this,"Starting Sequences");
    sequence_inst.start(env.agent.sequencer);
    #100; //hacking to get 100 coverage 
    phase.drop_objection(this,"Starting Sequences");

  endtask 
    
    function void connect_phase (uvm_phase phase);
   	  super.connect_phase(phase);
      // $display("connect_test");

    endfunction
endclass

endpackage

///////////////////////////////here___End_of_Package//////////////////////////////////////




//interface
/////////////////////////////////
interface intf();
  
  logic [31:0] Data_in;
  logic [3:0] Address;
  logic write_En,read_En,rst;
  logic [31:0] Data_out;
   `include "clk_generation.sv"

endinterface


//////////////////////Top_______Module///////////////////////////////
module memory_tb();
  import uvm_pkg::*;
  import pack1::*;
  
  
  intf in1();
  
  memory m1(in1.Data_in,in1.Address,in1.write_En,in1.read_En,in1.clk,in1.rst,in1.Data_out);
  
  initial begin
    uvm_config_db #(virtual intf) ::set (null,"uvm_test_top","my_vif",in1);
    run_test("my_test");
  end
  




endmodule