local item = script.item

script.Parent.label.Text = item.Value.Name
script.Parent.value.Text = item.Value.Value

item.Value.Changed:Connect(function()
	script.Parent.value.Text = item.Value.Value
end)
