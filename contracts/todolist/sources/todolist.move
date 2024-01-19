module todolist_addr::todolist{
    use aptos_framework::event;
    use aptos_std::table::{Table,Self};
    use std::string::String;
    use aptos_framework::account;
    use std::signer;

    struct TodoList has key{
        tasks: Table<u64,Task>,
        set_task_event: event::EventHandle<Task>,
        task_counter: u64
    }
    struct Task has store, copy, drop{
        task_id: u64,
        address: address,
        content: String,
        completed: bool,
    }
    // Store - Task needs Store as its stored inside another struct (TodoList)
    // Copy - value can be copied (or cloned by value).
    // Drop - value can be dropped by the end of scope.

    // Errors
    const ENOT_INITIALIZED:u64 = 0;
    const ETASK_DOESNT_EXIST:u64 = 1;
    const ETASK_ALREADY_COMPLETED:u64 = 2;

    public entry fun create_list(account: &signer){
        let tasks_holder = TodoList {
            tasks: table::new(),
            set_task_event: account::new_event_handle<Task>(account),
            task_counter: 0
        };
        move_to(account, tasks_holder);
    }

    public entry fun create_task(account:&signer, content:String) acquires TodoList{
        let signer_address = signer::address_of(account);
        assert!(exists<TodoList>(signer_address), ENOT_INITIALIZED);
        let todolist = borrow_global_mut<TodoList>(signer_address);
        let counter = todolist.task_counter + 1;
        let new_task = Task{
            task_id: counter,
            address: signer_address,
            content,
            completed: false,
        };
        table::upsert(&mut todolist.tasks, counter, new_task);
        event::emit_event<Task>(
            &mut borrow_global_mut<TodoList>(signer_address).set_task_event,
            new_task
        );
    }

    public entry fun complete_task(account: &signer, task_id: u64) acquires TodoList{
        let signer_address = signer::address_of(account);
        assert!(exists<TodoList>(signer_address), ENOT_INITIALIZED);
        let todolist = borrow_global_mut<TodoList>(signer_address);
        assert!(table::contains(&todolist.tasks, task_id), ETASK_DOESNT_EXIST);
        let task_record = table::borrow_mut(&mut todolist.tasks, task_id);
        assert!(task_record.completed == false, ETASK_ALREADY_COMPLETED);
        task_record.completed = true;
    }

    #[test_only]
    use std::string;
    #[test(admin=@0x123)]
    public entry fun test_flow(admin:signer)acquires TodoList{
        account::create_account_for_test(signer::address_of(&admin));
        create_list(&admin);
        create_task(&admin, string::utf8(b"New Task"));
        let task_count = event::counter(&borrow_global<TodoList>(signer::address_of(&admin)).set_task_event);
        assert!(task_count == 1, 4);
        complete_task(&admin, 1);
    }
}