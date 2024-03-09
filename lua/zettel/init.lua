local Zettel = {}
Zettel.__index = Zettel

function Zettel.setup(config)
	local zettel = setmetatable({
		filename = "",
		template_file = config.template_file or nil,
		note_file_format = config.note_file_format or ".md",
		destination_location = config.destination_location or vim.fn.expand("%:p:h"),
		create_filename = config.create_filename or function(instance)
			instance.filename = vim.fn.input("Zettel name: ")
		end,
		placeholders = config.placeholders or {
			{
				pattern = "{{ID}}",
				run = function(instance)
					return instance.filename
				end,
			},
			{
				pattern = "{{DATE}}",
				run = function()
					return tostring(os.date("%x"))
				end,
			},
		},
	}, Zettel)

	return zettel
end

function Zettel:new()
	local destination_file = self:create_new_file()

	if destination_file then
		self:write_new_file(destination_file)
	end

	self:open_file()
	self:reset()
end

function Zettel:reset()
	self.filename = ""
end

function Zettel:open_file()
	vim.cmd("e" .. self:get_file_path())
end

function Zettel:get_filename_with_ext()
	return self.filename .. self.note_file_format
end

function Zettel:get_file_path()
	return self.destination_location .. "/" .. self:get_filename_with_ext()
end

function Zettel:run_placeholders(file_contents)
	for _, placeholder in ipairs(self.placeholders) do
		file_contents = file_contents:gsub(placeholder.pattern, placeholder.run(self))
	end

	return file_contents
end

function Zettel:get_template_file()
	local template_file = io.open(self.template_file, "r") -- Open the source file in binary mode to ensure compatibility with all file types

	if not template_file then
		return false, "Could not open template file for reading."
	end

	local contents = template_file:read("*a") -- Read the entire contents of the file
	template_file:close() -- Always remember to close the file after reading

	return contents
end

function Zettel:create_new_file()
	self.create_filename(self)

	if self.filename == "" then
		return false, "No filename provided."
	end

	local destination_file = io.open(self:get_file_path(), "r")

	if destination_file then
		destination_file:close()
		return false, "File already exists."
	end

	destination_file = io.open(self:get_file_path(), "wb") -- Open the destination file in binary mode

	if not destination_file then
		return false, "Could not create destination file for writing."
	end

	return destination_file
end

function Zettel:write_new_file(destination_file)
	local template_contents, err = self:get_template_file()

	if not template_contents then
		return false, err
	end

	local contents = self:run_placeholders(template_contents)

	destination_file:write(self:run_placeholders(contents))
	destination_file:close()
end

return Zettel
