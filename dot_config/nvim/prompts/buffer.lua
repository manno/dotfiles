return {
    code = function(args)
        local helpers = require("codecompanion.helpers.actions")
        return helpers.get_code(1, args.context.line_count)
    end,
}
