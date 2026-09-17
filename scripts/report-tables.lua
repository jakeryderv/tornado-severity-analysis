-- Keep report.md linked to notebook assets, but typeset the two wide tables from
-- their saved CSVs at readable print sizes instead of shrinking their PNG text.
local tables = {
  ['assets/tables/table_04_training_experiments.png'] = {
    csv = 'data/results/table_04_training_experiments.csv',
    size = 9,
    columns = {1, 2, 3, 4, 5, 6, 8, 9, 10},
    headings = {'Run', 'Optimizer / LR', 'L2', 'Dropout', 'Train\\\\acc.',
                'Val\\\\acc.', 'Train\\\\loss', 'Val\\\\loss', 'Val\\\\F1'},
    align = 'lcrrrrrrr',
  },
  ['assets/tables/table_06_feature_groups.png'] = {
    csv = 'data/results/table_06_feature_groups.csv',
    size = 10,
    columns = {1, 2, 3, 4, 5},
    headings = {'Feature set', 'Inputs', 'Val acc.', 'Val F1', 'Val EF MAE'},
    align = 'lrrrr',
  },
}

local function csv_fields(line)
  local fields, field, quoted, i = {}, '', false, 1
  while i <= #line do
    local c = line:sub(i, i)
    if c == '"' then
      if quoted and line:sub(i + 1, i + 1) == '"' then
        field = field .. '"'; i = i + 1
      else
        quoted = not quoted
      end
    elseif c == ',' and not quoted then
      fields[#fields + 1] = field; field = ''
    else
      field = field .. c
    end
    i = i + 1
  end
  fields[#fields + 1] = field
  return fields
end

local function escape(text)
  return (text:gsub('([%%&_$#{}])', '\\%1'))
end

function Para(el)
  if FORMAT ~= 'latex' or #el.content ~= 1 or el.content[1].t ~= 'Image' then return end
  local spec = tables[el.content[1].src]
  if not spec then return end
  local file = assert(io.open(spec.csv), 'Missing saved result table: ' .. spec.csv)
  local rows = {}
  for line in file:lines() do rows[#rows + 1] = csv_fields(line:gsub('\r$', '')) end
  file:close()
  local out = {
    '\\par\\begingroup\\singlespacing\\fontsize{' .. spec.size .. '}{12}\\selectfont',
    '\\setlength{\\tabcolsep}{2pt}\\renewcommand{\\arraystretch}{1.25}',
    '\\noindent\\begin{tabular*}{\\linewidth}{@{\\extracolsep{\\fill}}' .. spec.align .. '@{}}',
    '\\toprule',
  }
  local headers = {}
  for _, value in ipairs(spec.headings) do
    headers[#headers + 1] = '\\shortstack{\\bfseries ' .. value .. '}'
  end
  out[#out + 1] = table.concat(headers, ' & ') .. ' \\\\ \\midrule'
  for i = 2, #rows do
    local cells = {}
    for _, column in ipairs(spec.columns) do
      local value = assert(rows[i][column], 'Missing CSV column')
      local number = tonumber(value)
      if number then
        if column == 2 then value = string.format('%d', number)
        elseif spec.size == 9 and column == 4 then value = string.format('%.1f', number)
        else value = string.format('%.3f', number) end
      end
      cells[#cells + 1] = escape(value)
    end
    if rows[i][1]:match('^Final') then out[#out + 1] = '\\midrule' end
    out[#out + 1] = table.concat(cells, ' & ') .. ' \\\\'
  end
  out[#out + 1] = '\\bottomrule\\end{tabular*}\\par\\endgroup'
  if spec.size == 10 then out[#out + 1] = '\\vspace{6pt}' end
  return pandoc.RawBlock('latex', table.concat(out, '\n'))
end
