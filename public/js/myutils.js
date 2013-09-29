function noNullInputForm(id) {
  var textbox = "#" + id + "-box";
  var button = "#" + id + "-submit-btn";
  $(textbox).bind("change keyup",function(){
    var count = $(this).val().length;
    if (count > 0) $(button).attr('disabled', false);
    else $(button).attr('disabled', true);
  });
};

$(function(){
  noNullInputForm("todo");
  noNullInputForm("search");
});
