module owner::hello_blockchain{
    use std::signer;
    use std::string::{String,utf8};
    struct Message has key{
        my_message: vector<u8>
    }

    const ENOT_INITIALIZED:u64 = 0;
    public entry fun create_message(account: &signer, new_message: vector<u8>) acquires Message {
        let signer_address = signer::address_of(account);
        if(exists<Message>(signer_address)){
            let my_message = &mut borrow_global_mut<Message>(signer_address).my_message;
            *my_message = new_message;
        }else{
            let new_message = Message {
                my_message: new_message
            };
            move_to(account, new_message);
        }
    }

    #[view]
    public fun get_message(addr: address):String acquires Message{
        assert!(exists<Message>(addr), ENOT_INITIALIZED);
        let my_message = borrow_global<Message>(addr).my_message;
        utf8(my_message)
    }

    #[test_only]
    use aptos_framework::account;
    use std::debug::print;
    #[test(account=@123)]
    public fun testing(account: signer) acquires Message{
        account::create_account_for_test(signer::address_of(&account));
        create_message(&account, b"Hello Aptos");
        let my_message = get_message(signer::address_of(&account));
        print(&my_message);
    }
}