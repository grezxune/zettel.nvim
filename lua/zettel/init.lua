local Zettel = {}
Zettel.__index = Zettel

function Zettel.setup(config)
	local zettel = setmetatable({
		filename = "",
		template_file = config.template_file or nil,
		note_file_format = config.note_file_format or ".md",
		destination_location = config.destination_location or vim.fn.expand("%:p:h"),
		placeholders = {},
	}, {})

	local instance = zettel

	if not config.placeholders then
		zettel.placeholders = {
			{
				pattern = "{{ID}}",
				value = function()
					return instance.filename
				end,
			},
			{
				pattern = "{{DATE}}",
				value = function()
					return tostring(os.date("%x"))
				end,
			},
		}
	else
		zettel.placeholders = config.placeholders
	end

	return zettel
end

function Zettel:new()
	self:update_filename()
	self:copy_template_file()
	self:open_file()
end

function Zettel:open_file()
	vim.cmd("e" .. self:get_file_path())
end

function Zettel:update_filename()
	self.filename = tostring(os.date("%m%d%Y%H%M%S"))
end

function Zettel:get_filename_with_ext()
	return self.filename .. self.note_file_format
end

function Zettel:get_file_path()
	return self.destination_location .. "/" .. self:get_filename_with_ext()
end

function Zettel:insert_placeholders(file_contents)
	for _, placeholder in ipairs(self.placeholders) do
		file_contents = file_contents:gsub(placeholder.pattern, placeholder.value(self))
	end

	return file_contents
end

function Zettel:copy_template_file()
	local source_file = io.open(self.template_file, "rb") -- Open the source file in binary mode to ensure compatibility with all file types

	if not source_file then
		return false, "Could not open source file for reading."
	end

	local contents = source_file:read("*a") -- Read the entire contents of the file
	source_file:close() -- Always remember to close the file after reading

	local destinationFile = io.open(self:get_file_path(), "wb") -- Open the destination file in binary mode
	if not destinationFile then
		return false, "Could not open destination file for writing."
	end

	destinationFile:write(self:insert_placeholders(contents))
	destinationFile:close()

	return true
end

return Zettel
