return function (source)
    local new_module = Instance.new('ModuleScript')
    new_module.Name = "InterpretModule"
    new_module.Source = source
    local return_value = require(new_module)
    new_module:Destroy()
    return return_value
end