// UVM Exercise 3
// Question 1
// Register all the classes in the previous lab using the UVM
// registeration macros, then define a dummy constructor in each class
// -------------------------------------------------------------------//
// Question 2
// Instantiate Env, Agent, Scoreboard, Subscriber, Driver, Monitor & Sequencer
// then call the create method inside the build phase of each class
  // -------------------------------------------------------------------//
package my_pack;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  /////////////////////////////////////////////////////////////////////
  // Transaction Class
  ////////////////////////////////////////////////////////////////////
  class my_transaction extends uvm_sequence_item;
    // Registering the my_transaction on the factory
    `uvm_object_utils(my_transaction)

    // Constructor
    function new(string name="my_transaction");
      super.new(name);
      $display("[Transaction]\t Hi from my_transaction class");
    endfunction: new

  endclass: my_transaction

  /////////////////////////////////////////////////////////////////////
  // Driver Class
  ////////////////////////////////////////////////////////////////////
  class my_driver extends uvm_driver #(my_transaction);
    // Registering the my_driver on the factory
    `uvm_component_utils(my_driver)

    // Constructor
    function new(string name="my_driver", uvm_component parent=null);
      super.new(name, parent);
      $display("[Driver]\t Hi from my_driver class");
    endfunction: new

    // Function: build_phase
    function void build_phase (uvm_phase phase);
      super.build_phase(phase);
      $display("[Driver]\t Build Phase");
    endfunction: build_phase

    // Function: connect_phase
    function void connect_phase (uvm_phase phase);
      super.connect_phase(phase);
      $display("[Driver]\t Connect Phase");
    endfunction: connect_phase

    // Task: run_phase
    task run_phase (uvm_phase phase);
      super.run_phase(phase);
      $display("[Driver]\t Run Phase");
    endtask: run_phase

  endclass: my_driver 

  /////////////////////////////////////////////////////////////////////
  // Monitor Class
  ////////////////////////////////////////////////////////////////////
  class my_monitor extends uvm_monitor;
    // Registering the my_monitor on the factory
    `uvm_component_utils(my_monitor)

    // Constructor
    function new(string name="my_monitor", uvm_component parent=null);
      super.new(name, parent);
      $display("[Monitor]\t Hi from my_monitor class");
    endfunction: new

    // Function: build_phase
    function void build_phase (uvm_phase phase);
      super.build_phase(phase);
      $display("[Monitor]\t Build Phase");
    endfunction: build_phase

    // Function: connect_phase
    function void connect_phase (uvm_phase phase);
      super.connect_phase(phase);
      $display("[Monitor]\t Connect Phase");
    endfunction: connect_phase

    // Task: run_phase
    task run_phase (uvm_phase phase);
      super.run_phase(phase);
      $display("[Monitor]\t Run Phase");
    endtask: run_phase

  endclass: my_monitor

  /////////////////////////////////////////////////////////////////////
  // Agent Class
  ////////////////////////////////////////////////////////////////////
  class my_agent extends  uvm_agent;
    // Registering the my_agent on the factory
    `uvm_component_utils(my_agent)

    // Intances of Monitor, Driver and Sequencer classes
    my_driver drvr;
    my_monitor mon;
    uvm_sequencer #(my_transaction) sequr;

    // Constructor
    function new(string name="my_agent", uvm_component parent=null);
      super.new(name, parent);
      $display("[Agent]\t Hi from my_agent class");
    endfunction: new

    // Function: build_phase
    function void build_phase (uvm_phase phase);
      super.build_phase(phase);
      $display("[Agent]\t Build Phase");

      // Create instances of the monitor and driver for the phases
      // to be seen and for the messages to be printed
      sequr = uvm_sequencer#(my_transaction)::type_id::create("sequr", this);
      drvr  = my_driver::type_id::create("drvr", this);
      mon  = my_monitor::type_id::create("mon", this);
    endfunction: build_phase

    // Function: connect_phase
    function void connect_phase (uvm_phase phase);
      super.connect_phase(phase);
      $display("[Agent]\t Connect Phase");
    endfunction: connect_phase

    // Task: run_phase
    task run_phase (uvm_phase phase);
      super.run_phase(phase);
      $display("[Agent]\t Run Phase");
    endtask: run_phase

  endclass: my_agent

  /////////////////////////////////////////////////////////////////////
  // Scoreboard Class
  ////////////////////////////////////////////////////////////////////
  class my_scoreboard extends uvm_scoreboard; 
    // Registering the my_scoreboard on the factory
    `uvm_component_utils(my_scoreboard)

    // Constructor
    function new(string name="my_scoreboard", uvm_component parent=null);
      super.new(name, parent);
      $display("[Scoreboard]\t Hi from my_scoreboard class");
    endfunction: new

    // Function: build_phase
    function void build_phase (uvm_phase phase);
      super.build_phase(phase);
      $display("[Scoreboard]\t Build Phase");
    endfunction: build_phase

    // Function: connect_phase
    function void connect_phase (uvm_phase phase);
      super.connect_phase(phase);
      $display("[Scoreboard]\t Connect Phase");
    endfunction: connect_phase

    // Task: run_phase
    task run_phase (uvm_phase phase);
      super.run_phase(phase);
      $display("[Scoreboard]\t Run Phase");
    endtask: run_phase

  endclass: my_scoreboard 

  /////////////////////////////////////////////////////////////////////
  // Subscriber Class
  ////////////////////////////////////////////////////////////////////
  class my_subscriber extends uvm_subscriber #(my_transaction);  
    // Registering the my_subscriber on the factory
    `uvm_component_utils(my_subscriber)

    // Constructor
    function new(string name="my_subscriber", uvm_component parent=null);
      super.new(name, parent);
      $display("[Subscriber]\t Hi from my_subscriber class");
    endfunction: new
    
    // Function: write
    // pure virtual method that is declared in the uvm_subscriber
    // The following isn't working on Questa
    // function void write (my_transaction trans);
    // Link: https://verificationacademy.com/forums/uvm/any-one-please-resolve-code-error-uvm-subscriber-write-function
    function void write (my_transaction t);
    endfunction: write

    // Function: build_phase
    function void build_phase (uvm_phase phase);
      super.build_phase(phase);
      $display("[Subscriber]\t Build Phase");
    endfunction: build_phase

    // Function: connect_phase
    function void connect_phase (uvm_phase phase);
      super.connect_phase(phase);
      $display("[Subscriber]\t Connect Phase");
    endfunction: connect_phase

    // Task: run_phase
    task run_phase (uvm_phase phase);
      super.run_phase(phase);
      $display("[Subscriber]\t Run Phase");
    endtask: run_phase

  endclass: my_subscriber 

  /////////////////////////////////////////////////////////////////////
  // Environment Class
  ////////////////////////////////////////////////////////////////////
  class my_env extends uvm_env;
    // Fixing the following error 
    //  "Error-[MFNF] Member not found uvm_classes.sv,
    //   261 "my_env::type_id" Could not find member 'type_id' in class 'my_env', at "uvm_classes.sv"
    // link: https://forums.accellera.org/topic/2158-type_id-not-in-scope-when-deriving-an-uvm_object/
    // Registering the my_env on the factory
    `uvm_component_utils(my_env)

    // Intances of Agent, Scoreboard and Subscriber classes
    my_agent      agent;
    my_scoreboard scb;
    my_subscriber sub;

    // Constructor
    // For the environment class constuctor, as it's a component, 
    // need to add to the constuctor the name and the parent.
    // otherwise it will throw an error
    // link: https://verificationacademy.com/forums/uvm/error-tmatc
    function new(string name="my_env", uvm_component parent=null);
      super.new(name, parent); // missing the "parent" argument will break the chain
      $display("[Environment]\t Hi from my_env class");
    endfunction

    // Function: build_phase
    function void build_phase (uvm_phase phase);
      super.build_phase(phase);
      $display("[Environment]\t Build Phase");
      
      // Create instances of the agent, scoreboard and subscriber 
      // for the phases to be seen and for the messages to be printed
      agent = my_agent::type_id::create("agent", this);
      scb   = my_scoreboard::type_id::create("scb", this);
      sub   = my_subscriber::type_id::create("sub", this);
    endfunction: build_phase

    // Function: connect_phase
    function void connect_phase (uvm_phase phase);
      super.connect_phase(phase);
      $display("[Environment]\t Connect Phase");
    endfunction: connect_phase

    // Task: run_phase
    task run_phase (uvm_phase phase);
      super.run_phase(phase);
      $display("[Environment]\t Run Phase");
    endtask: run_phase

  endclass: my_env 

  /////////////////////////////////////////////////////////////////////
  // Test Class
  ////////////////////////////////////////////////////////////////////
  class my_test extends uvm_test;
	  // Fixing the following error 
    //  "UVM_WARNING @ 0: reporter [BDTYP] Cannot create a component of type 'my_test' because it is not registered with the factory."
    //  "UVM_FATAL @ 0: reporter [INVTST] Requested test from call to run_test(my_test) not found."
    // link: https://verificationacademy.com/forums/uvm/cannot-create-component-type-test2-because-it-not-registered-factory
    // Registering the my_test on the factory
    `uvm_component_utils(my_test)
    
    // Intances of Environment classe
    my_env env;

    // Constructor
    function new(string name="my_test", uvm_component parent=null);
      super.new(name, parent);
      $display("[Test]\t Hi from my_test class");
    endfunction

    // Function: build_phase
    function void build_phase (uvm_phase phase);
      super.build_phase(phase);
      $display("[Test]\t Build Phase");

      // Create instance of the environment 
      // for the phases to be seen and for the messages to be printed
      env = my_env::type_id::create("env", this);
    endfunction: build_phase

    // Function: connect_phase
    function void connect_phase (uvm_phase phase);
      super.connect_phase(phase);
      $display("[Test]\t Connect Phase");
    endfunction: connect_phase

    // Task: run_phase
    task run_phase (uvm_phase phase);
      super.run_phase(phase);
      $display("[Test]\t Run Phase");
    endtask: run_phase
    
  endclass: my_test

endpackage: my_pack

module top();
  import uvm_pkg::*;
  import my_pack::*;
  
  initial begin
    run_test("my_test");
  end
  
endmodule
