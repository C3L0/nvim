return {
    {
        "mfussenegger/nvim-dap",
    },
    {
        "mfussenegger/nvim-dap-python",
        dependencies = { "mfussenegger/nvim-dap" },
        config = function()
            local dap_python = require("dap-python")
            -- Replace with your actual Python path if needed
            dap_python.setup("python")
        end,
    },
    {
	"rcarriga/nvim-dap-ui",
	dependencies = {
		"mfussenegger/nvim-dap",
		"nvim-neotest/nvim-nio",
	    },
	config = function()
	    local dap, dapui = require("dap"), require("dapui")

	    vim.keymap.set("n", "<F5>", dap.continue)
	    vim.keymap.set("n", "<F10>", dap.step_over)
	    vim.keymap.set("n", "<F11>", dap.step_into)
	    vim.keymap.set("n", "<F12>", dap.step_out)
	    vim.keymap.set("n", "<Leader>b", dap.toggle_breakpoint)
	    vim.keymap.set("n", "<Leader>B", function()
		dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
	    end)

	    dapui.setup()

	    -- Auto open/close UI when debugging starts/ends
	    dap.listeners.after.event_initialized["dapui_config"] = function()
		dapui.open()
	    end
	    dap.listeners.before.event_terminated["dapui_config"] = function()
		dapui.close()
	    end
	    dap.listeners.before.event_exited["dapui_config"] = function()
		dapui.close()
	    end
	end,
    },
}

