function openReplyDlgFor(id) {
  $("#reply_dlg_"+id).show();
}
function closeReplyDlgFor(id) {
  $("#reply_dlg_"+id).hide();
}
function saveReplyFor(id) {
  var form = $("#reply_dlg_"+id);
  form.find(".replymsg").html("Saving.");
  $.post("save", {
      text: form.find(".text").val(),
      parent_pk: form.find(".post_pk").val(),
      parent_date: form.find(".post_date").val(),
    }, null, "json"
  ).done(function(data) {
    if (data.success) {
      closeReplyDlgFor(id);
      $(data.html).insertAfter(form);
    } else {
      form.find(".replymsg").html(data.message);
    }
  }).fail(function(xhr, textStatus, errorThrown) {
    form.find(".replymsg").html("An error has occurred: "+textStatus+", "+errorThrown+" '"+xhr.responseText+"'");
  });
}
function updateVoteRating(delta, newvalue, element, id) {
  var parent = element.closest(".commentwrapper");
  var pointelem = parent.find(".pointvalue");
  var pointval = parseInt(pointelem.text());
  pointval += delta;
  pointelem.text(pointval);
  var form = $("#reply_dlg_"+id);
  $.post("vote", {
      post_pk: form.find(".post_pk").val(),
      post_date: form.find(".post_date").val(),
      rating: newvalue,
    }, null, "json"
  ).done(function(data) {
    // what to even do here?
  }).fail(function(xhr, textStatus, errorThrown) {
    form.show();
    form.find(".replymsg").html("Couldn't submit vote: "+textStatus+", "+errorThrown+" '"+xhr.responseText+"'");
  });
}
function upvoteFor(element, id) {
  var upvote = $(element);
  var downvote = upvote.closest(".votewrapper").find(".downvote");
  var delta = 0;
  if (downvote.hasClass("selected")) delta += 1;
  downvote.removeClass("selected");
  upvote.toggleClass("selected");
  var newvalue = 0;
  if (upvote.hasClass("selected")) {
    delta += 1;
    newvalue = 1;
  } else {
    delta -= 1;
  }
  updateVoteRating(delta, newvalue, upvote, id);
}
function downvoteFor(element, id) {
  var downvote = $(element);
  var upvote = downvote.closest(".votewrapper").find(".upvote");
  var delta = 0;
  if (upvote.hasClass("selected")) delta -= 1;
  upvote.removeClass("selected");
  downvote.toggleClass("selected");
  var newvalue = 0;
  if (downvote.hasClass("selected")) {
    delta -= 1;
    newvalue = -1;
  } else {
    delta += 1;
  }
  updateVoteRating(delta, newvalue, downvote, id);
}
