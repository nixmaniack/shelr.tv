# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $('.alert').alert().bind 'closed', (ev) ->
    jQuery.cookie("saw-#{$(ev.target).attr('id')}", true);
  $('.dashboard .comment').click (ev) ->
    location.href = $(this).find('.updated_at a').attr('href')
