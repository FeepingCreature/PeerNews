- Copied from http://piratepad.net/CeTPAJl5LR

## INTRODUCTION
 
PeerNews is a P2P distributed Reddit clone.
 
## DESCRIPTION
 
A peer is a computer running the PeerNews software.
 
Each peer is subscribed to a number of other peers, on a number of topics. (Tags or Posts)
 
On startup, the peer announces its ip/identity pair(s) to the world. This will be initially done via a central "master server", because it's an iffy problem that takes code to solve. After we grow past a thousand users or so, we can transition to a DHT.
 
Peer keeps a database of StoredThreadState it has received from its Friends.
At regular intervals, it asks Peers for their StoredThreadState
(SubscribedTags/SubscribedPosts)and, if all contained signatures pass validation,
replaces (augments?) its stored state for this Peer with the update.
 
Peer has a database of upvotes/downvotes.
 
Peer lazily generates its own opinion of a thread's state. This is done by, for
each post, looking at the stored states it has for that post and forming a weighted and
capped average, then applying its own upvotes/downvotes to the aggregate, recursively,
until a set limit is reached. (Priority queue by upvotes?) This
aggregate is made available in HTML and JSON form on request. When displayed as
HTML, each post has a gravatar based on its signature. When sent as JSON, the
package is signed with the hoster's identity. 
 
Posts have the following actions: upvote, downvote, hide, delete, edit, [listen, believe, trust].
The listen, believe and trust actions add an identity to the peer list with a given trust rating.
 
## PROPOSED TECHNOLOGIES, INTERESTING READING
 
 * http://www.pjsip.org/pjnath/docs/html/ ?
 * https://en.gravatar.com/site/implement/hash/
 * libsodium seems nice for the crypto
  * http://doc.libsodium.org/public-key_cryptography/public-key_signatures.html
 * Reddit's markdown renderer is opensource
   * https://github.com/reddit/snudown
 * would we form a http://en.wikipedia.org/wiki/Small-world_network ?
   * (like freenet)
 * oh btw, see also http://en.wikipedia.org/wiki/Syndie
 
## UNFLESHED OUT IDEAS
 
* Automatically subscribe (locally) to people you reply to (enables conversations)
* Peer discovery! Figure out a way to find the current IP for a node. (Verify its signature when connecting! "Ping" - "Are you X" request)
  * I don't know if it's enough to just send it to your friends.
  * Keep this part extensible so you can possibly slot in a DHT later
  * Fall back on a central announcement server? Especially in the beginning.
  * bootstrap the peer dht by piggybacking off the bittorrent dht?
   * <Zarutian> feep: a bit of a tip for p2p peer bootstraping. One way is to use bittorrents DHT to find the first few nodes. (Those nodes are offering a "fake" torrent at specified hardcoded infohash)
* login function for comment posting via mobile etc. Mobile server?
* When trusting an identity, automatically delete posts by users of the same nick but a different key
* When receiving updates that contain massively mismatched signatures (posts with same content/nick but different key), automatically distrust the source?
  * Isolate mass-mimicry attempts, somehow.
    * Should happen automatically via volume limiting. Need to make it tighter? Not sure.
* Popular peers may end up swamped with requests. To alleviate this, send a cheap Redirect
  to a peer who has a current version of their thread state. 
* Deleted comments are forwarded with empty content?
* Cache Gravatar locally for security reasons
* "Vote Echo Problem"!! Upvotes echo between circular peers.
  * Not sure how to address.
 * Central "random peers" server for opennet/bootstrapping?
 
 
## RELEASE BLOCKERS
 
* NAT traversal
* IP discovery (ask around?)
  * Subscribe clients to a central Identity/IP database by default
    * (a peer that has no posts, just Identity/IP data?)
    * Special mode of peering? Necessary?
 
## TASKS
 
- Discover public IP
 - Stub this: just load ifconfig.me
- Render a thread
- Authenticate a user
 - Stub: check for localhost
- http server
 - find library?
- http client
 
## DATA STRUCTURE SKETCHES ETC

* TODO rederive from create-peernewsdb.sh
* THESE ARE OUT OF DATE!!

Identity: Nickname, PubKey
 
RatedPost: PlainPost, VoteMedian, VoteControversy
 
TopPost: RatedPost, Link, TopicTag
 
ChildPost(Root, Post) = Post is Root.RatedPost.PlainPost or ChildPost(Root, Post.Parent)
 
StoredThreadState: TopPost, DateReceived, SourceIdentity, {RatedPost where ChildPost(TopPost, RatedPost.PlainPost)}
 
Peer: Identity, TrustRating(0..1), [Domain]
  Domain is the reason why we're paying attention to a Peer.
  When responding to a post, this is set to the post's key unless
  we're already paying attention to this Peer for other reasons.
  When Trusting, it's left empty.
 
TopicState(Tag): {StoredThreadState where StoredThreadState.TopPost.TopicTag = Tag}
 
Vote: Hash, Rating
 
TrustCap(TrustRating) = 1/(1 - TrustRating)
  TrustRating TrustCap Comment
  0           1        Default rating for automatic trust
  0.5         2
  0.8         5
  0.9         10       Listen
  0.99        200      Believe
  0.999       1000     Trust
