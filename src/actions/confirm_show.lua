return function (text, onConfirm, onCancel)
	return {
		type = script.Name;
		confirm = {
			show = true;
			text = text;
			onConfirm = onConfirm;
			onCancel = onCancel;
		}
	}
end