$(function(){
  $("#todo-box").bind("change keyup",function(){
    var count = $(this).val().length;
    if (count > 0) $("#todo-submit-btn").attr('disabled', false);
    else $("#todo-submit-btn").attr('disabled', true);
  });
});
