# Gwei Optimization

> ```
>  --optimize-runs n (=200)
>                        Estimated number of contract runs for optimizer tuning.
> ```
>
> The `runs` option is not about how often the optimizer is run (it is always run until there is nothing left to improve). Instead, the optimizer has to operate under a trade-off situation: You can optimizer the code for size (i.e. deployment costs) or for runtime costs ("speed"). This trade-off is different in situations where you deploy the code only once, run it and destroy the contract again as opposed to a contract that is deployed and then use multiple thousand times. Because of that, the optimizer allows for a linear factor to balance between these two criteria that roughly represents how often each opcode will be run after the contract has been deployed. Since the costs for deployment matter less and less the more often you run invoke the contract, it will get longer with increasing arguments to the `runs` option.

> I found a curious result when upgrading Truffle to Solidity 0.4.11 (via solc-js). It seems that the more the optimizer is run, the longer my bytecode gets. This suggests to me that the optimizer is adding instructions instead of removing them.
>
> The contract in question is [this one](https://github.com/trufflesuite/truffle/blob/master/lib/testing/Assert.sol?rgh-link-date=2017-05-05T20%3A42%3A44Z). This is Truffle's assertion library for its Solidity tests, which is so large that it could possibly overflow the block gas limit. This contract relies on the optimizer to ensure the that it can be deployed free and clear.
>
> When upgrading from Solidity 0.4.8 to 0.4.11, I used the default/example configuration [from here](https://solidity.readthedocs.io/en/develop/using-the-compiler.html#compiler-input-and-output-json-description) to specify my optimizer settings. That configuration, for me, looks like this:
>
> ```
>   {
>     "language": "Solidity",
>     "sources": {
>       "Assert.sol": {
>         "content": "..."
>       }
>     },
>     "settings": {
>       "optimizer": {
>         "enabled": true,
>         "runs": 500
>       },
>       "outputSelection": {
>         "*": {
>           "*": [
>             "abi",
>             "ast",
>             "evm.bytecode.object",
>             "evm.bytecode.sourceMap",
>             "evm.deployedBytecode.object",
>             "evm.deployedBytecode.sourceMap"
>           ]
>         },
>       }
>     }
>   }
> ```
>
> With this configuration, exactly as it stands, this contract will overflow the block gas limit of `4712388` when deployed. The character length of the resulting bytecode is 35242 characters long. When I _increase_ the number of runs the optimizer makes, curiously, the longer the code becomes. Inversely, if I run the optimizer as little as possible without turning it off, the shorter the resulting bytecode. Here's a list of findings:
>
> Optimizer enabled Optimizer runs Code length (characters) Contract deployable
> Yes 0 33900 Yes
> Yes 1 to 13 33900 Yes
> Yes 14 33908 Yes
> Yes 100 34506 Yes
> Yes 250 34906 Yes
> Yes 400 35242 No
> Yes 500 35242 No
> Yes 1000 35946 No
> Yes 10000 40646 No
> No N/A 44380 No
> It would appear that the optimizer _is_ optimizing for space/code length when turned on. However, if you run it (i.e., runs > 0), the more instructions or data it appears to add to the resulting bytecode. My only guess is that this is meant to optimize for transaction costs for certain transactions by replacing costly instructions with cheaper, less costly versions (though using more of them), but I haven't looked deeper.
>
> One interesting result that I included in the table: runs `0` through `13` all produce the same code length, but different bytecode. I'm unsure if this is significant, but `runs = 14` is where I saw the first change in code length.
>
> For Truffle users, I plan to default to `runs = 0` as smaller code (i.e., ability to deploy) is more valuable than slightly cheaper transaction costs. I'll likely let users configure this option in the future.

> ```
>  --optimize-runs n (=200)
>                        Estimated number of contract runs for optimizer tuning.
> ```
>
> The `runs` option is not about how often the optimizer is run (it is always run until there is nothing left to improve). Instead, the optimizer has to operate under a trade-off situation: You can optimizer the code for size (i.e. deployment costs) or for runtime costs ("speed"). This trade-off is different in situations where you deploy the code only once, run it and destroy the contract again as opposed to a contract that is deployed and then use multiple thousand times. Because of that, the optimizer allows for a linear factor to balance between these two criteria that roughly represents how often each opcode will be run after the contract has been deployed. Since the costs for deployment matter less and less the more often you run invoke the contract, it will get longer with increasing arguments to the `runs` option.
