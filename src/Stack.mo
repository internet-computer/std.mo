import { Array_init; Array_tabulate } = "mo:⛔";

import Iterator "Iterator";

module Stack {
    /// An extendable mutable stack.
    /// - __capacity__ : The capacity of the stack, is used to initialize if xs.size() == 0.
    /// - __size__ : The current occupied size.
    /// - __xs__ : The managed backbone array of the stack.
    public type Stack<T> = {
        var capacity : Nat;
        var size     : Nat;
        var xs       : [var T];
    };

    /// Initializes a new stack with the given capacity.
    public func init<T>(capacity : Nat) : Stack<T> {
        return {
            var capacity = capacity;
            var size     = 0;
            var xs       = [var];
        };
    };

    /// Makes a new stack based on the given array.
    public func make<T>(xs : [T]) : Stack<T> {
        let size = xs.size();
        {
            var capacity = size;
            var size;
            var xs       = _make(xs);
        };
    };

    private func _make<T>(xs : [T]) : [var T] {
        let size = xs.size();
        if (size == 0) return [var];
        let ys = Array_init<T>(size, xs[0]);
        for (i in ys.keys()) ys[i] := xs[i];
        ys;
    };

    /// Creates an empty stack with capacity 0.
    public func empty<T>() : Stack<T> {
        make([]);
    };

    public func get<T>(b : Stack<T>, index : Nat) : ?T {
        if (index >= b.size) return null;
        ?b.xs[index];
    };

    /// Adds the given value 'x' to the stack.
    public func push<T>(b : Stack<T>, x : T) {
        if (b.size == b.xs.size()) {
            let size = if (b.size == 0) {
                if (0 < b.capacity) { b.capacity } else { 1 };
            } else { 2 * b.xs.size() };
            let ys = Array_init<T>(size, x);

            var i = 0;
            label l loop {
                if (b.size <= i) break l;
                ys[i] := b.xs[i];
                i += 1;
            };
            b.xs       := ys;
            b.capacity := size;
        };

        b.xs[b.size] := x;
        b.size       += 1;
    };

    /// Removes the last value from the stack and returns it.
    public func pop<T>(b : Stack<T>) : ?T {
        if (b.size == 0) return null;
        b.size -= 1;
        ?b.xs[b.size];
    };

    /// Returns the last value from the stack without removing it.
    public func last<T>(b : Stack<T>) : ?T {
        if (b.size == 0) return null;
        ?b.xs[b.size - 1];
    };

    /// Extracts an array from the stack.
    public func toArray<T>(b : Stack<T>) : [T] {
        Array_tabulate<T>(b.size, func(i : Nat) : T { b.xs[i] });
    };

    public func values<T>(b : Stack<T>) : Iterator.Iterator<T> = object {
        var n = 0;
        public func next() : ?T {
            if (n == b.size) return null;
            let x = ?b.xs[n];
            n += 1;
            x;
        };
    };

    public module Autofill = {
        public type Stack<T> = Stack.Stack<T> and {
            var index : Nat;
            iter : Iterator.Iterator<T>;
        };

        public func init<T>(capacity : Nat, iter : Iterator.Iterator<T>) : Stack<T> {
            return {
                var capacity = capacity;
                var size     = 0;
                var xs       = [var];
                var index    = 0;
                iter;
            };
        };

        public func get<T>(s : Stack<T>, index : Nat) : ?T {
            if (index >= s.capacity) return null;

            while (s.size <= index) switch (s.iter.next()) {
                case (? v) {
                    Stack.push(s, v);
                };
                case (_) return null;
            };
            Stack.get(s, index);
        };
    };
};
