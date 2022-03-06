# crowdfund. getting rewarded for hard work is nice
Crowdfund is a protocol for rewarding people who create things that people like.

## summary
Say I'm a writer and I want more money for writing so I can spend time writing. First, I'll call `requestFunding()` on the contract so I can announce to the world that I want more money to write. I attach a url (on ipfs or not!) where I document what I'm writing about and how often people can expect me to publish if they donate tokens.

Someone on the vast internet finds my request, and they decide to contribute funding to my writing project. They can call `fundProject()` on the contract to donate some tokens to me. I can claim these tokens by calling `claimFunding()` if I've completed the writing I've promised. 

Hm, what if I'm a rug-pull writer, how can we trust that I'll deliver my writing at all?

The contract uses the Tellor oracle to hold me accountable. Otherwise, I won't get any tokens! When I call `requestFunding()`, I send some tokens to the Tellor oracle so someone can make sure I'm not a rug-pull writer. Tellor will automatically reward its data reporters for submitting on-chain whether or not I've delievered the writing I promised (writing the next great american novel isn't easy...). If the Tellor network declares that I haven't delievered on my promise, anyone can call `defaultArtist()` to return everyone's unclaimed contributions to my project.