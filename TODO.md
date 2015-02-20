Tasks left:

* send port in the /register request, don't assume it's 8899
* make /register POST-only (once it works)
* replace nonce tracking with a hashmap
* create database to store pk-address mappings
* implement /get-address-for-pk

0.01 default view:

* Load identity from the config file.
  * DONE
* If no top-level post exists, create a default top-level post.
  * (Title "Hello World", link to example.com, etc).
  * DONE
* Show this post.
  * DONE
* Show a "reply" form.
  * DONE
* Save the comment to the db.
  * DONE
* Echo back the comment on submit. (JQuery partial replace!)
  * DONE
* Echo it back with sundown^Whoedown.
  * DONE
* Test comment hierarchy.
  * DONE
* (Implement editing?)
* Implement voting.
* Public test 0.01
* Implement JSON export.
