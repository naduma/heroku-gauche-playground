$(function() {
	var initCode = '(define (main args)\n  (display "Hello, world!\\n")\n  0)';
	$('textarea').val(initCode);
	$('textarea').numberedtextarea();

	$('button').on('click', function() {
		$.ajax({
			url: '/eval',
			data: {
				code: $('textarea').val()
			},
			beforeSend: function() {
				$('#result').html('');
				$('#status').html('Waiting...');
			}
		}).done(function(data) {
			$('#result').html(data.result);
		}).fail(function() {
			$('#result').html('An error occurred, please try again later.');
		}).always(function(data) {
			$('#status').html('Done.');
		});
	});
});
