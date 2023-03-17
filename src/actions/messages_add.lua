return function (type, text, delay)
	return {
		type = script.Name;
		delay = delay;
		message = {
			type = type;
			Text = text or type == 'info' and 2.5 or 5;
		}
	}
end