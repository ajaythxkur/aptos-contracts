module coin_admin::basic_coin{
    use std::signer;

    struct Coins has store, drop{ 
        val: u64 
    }
    struct Balance has key{
        coins: Coins
    }

    //ERR_CODES
    const EBALANCE_ALREADY_EXISTS:u64 = 0;
    const EBALANCE_NOT_EXISTS:u64 = 1;
    const EINSUFFICIENT_BALANCE:u64 = 2;
    const EEQUAL_ADDR:u64 = 3;

    public fun create_balance(acc: &signer){
        let acc_addr = signer::address_of(acc);
        assert!(!balance_exists(acc_addr),EBALANCE_ALREADY_EXISTS);
        let zero_coins = Coins {
            val: 0
        };
        move_to(acc, Balance { coins: zero_coins });
    }
    inline fun balance_exists(acc_addr: address):bool{
        exists<Balance>(acc_addr)
    }

    public fun deposit(acc_addr: address, coins: Coins) acquires Balance {
        assert!(balance_exists(acc_addr), EBALANCE_NOT_EXISTS);
        let balance = balance(acc_addr);
        let balance_ref = &mut borrow_global_mut<Balance>(acc_addr).coins.val;
        let Coins { val } = coins;
        *balance_ref = balance + val;
    }
    inline fun balance(acc_addr: address):u64 acquires Balance{
        borrow_global<Balance>(acc_addr).coins.val
    }

    public fun withdraw(acc_addr: address, value: u64): Coins acquires Balance {
        assert!(balance_exists(acc_addr), EBALANCE_NOT_EXISTS);
        let balance = balance(acc_addr);
        assert!(balance >= value, EINSUFFICIENT_BALANCE);
        let balance_ref = &mut borrow_global_mut<Balance>(acc_addr).coins.val;
        *balance_ref = balance - value;
        Coins{ val: value } //withdraw amount
    }

    public fun transfer(from: &signer, to:address, amount:u64) acquires Balance{
        let from_addr = signer::address_of(from);
        assert!(from_addr != to, EEQUAL_ADDR);
        assert!(balance_exists(from_addr), EBALANCE_NOT_EXISTS);
        assert!(balance_exists(to), EBALANCE_NOT_EXISTS);
        let check = withdraw(from_addr, amount);
        deposit(to, check);
    }

    #[view]
    public fun balance_of(addr: address):u64 acquires Balance {
        assert!(exists<Balance>(addr), EBALANCE_NOT_EXISTS);
        borrow_global<Balance>(addr).coins.val
    }

    #[test_only]
    use aptos_framework::account;
    use std::debug::print;
    #[test(admin=@coin_admin)]
    public fun testing(admin:signer) acquires Balance{
        let addr = signer::address_of(&admin);
        account::create_account_for_test(addr);
        create_balance(&admin);
        let deposit_coin = Coins {
            val: 10
        };
        deposit(addr, deposit_coin);
        let account2 = account::create_account_for_test(@0x56);
        create_balance(&account2);
        transfer(&admin, @0x56, 2);
        let from_balance = balance_of(addr);
        let to_balance = balance_of(@0x56);
        print(&from_balance);
        print(&to_balance);
    }
}