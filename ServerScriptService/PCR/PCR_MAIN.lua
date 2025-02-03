local module = {}
local wait = task.wait
--CONFIG
local CELL_AMBIENT = 23
local CHAMBER_AMBIENT = 23
local COMBUSTION_TEMP = 300
local COMBUSTION_TEMP_RANGE = 5
local COMBUSTION_TEMP_LOW = COMBUSTION_TEMP-COMBUSTION_TEMP_RANGE
local COMBUSTION_HIGH = COMBUSTION_TEMP+COMBUSTION_TEMP_RANGE
local PLASMA_REACTION_TEMP = 700
local PLASMA_REACTION_TEMP_RANGE = 30
local PLASMA_COMBUSTION_POWER = 0.7
local PLASMA_REACTION_POWER = 12
local PLASMA_DISIPATION_RATE = 0.01
local PLASMA_IDEAL_DISAPATION_TEMP = 750
local PLASMA_CRITICAL_TEMP = 1300
local PLASMA_TO_CELL_DISIPATION = 0.2
local PI_INITIATION_TEMP = 150
local PI_INITIATION_TEMP_RANGE = 5
local PI_FUEL_TEMP = 19
local CELL_PLASMA_DIVIDER = 5
local CP_COOL_TO = CHAMBER_AMBIENT
local CP_POWER = 0.6
--RUNNING DATA
module.piTemp = {}
module.combustionTemp = {}
module.plasmaTemp = {{CHAMBER_AMBIENT}}
module.piFuelInput = {0}
module.cellPD = {}--Cell plasma density
module.cellTemp = {}
module.plasmaOutput = {}
module.coolingPump = {}
--vars
local temp
local item
------------
for x=1,4 do
	item = {}
	for y=1,6 do
		table.insert(item, CHAMBER_AMBIENT)
	end
	table.insert(module.piTemp, item)
end
for x=1,4 do
	table.insert(module.combustionTemp, CHAMBER_AMBIENT)
end
for x=1,4 do
	table.insert(module.plasmaTemp, CHAMBER_AMBIENT)
end
for x=1,4 do
	table.insert(module.piFuelInput, 0)
end
for x=1,4 do
	table.insert(module.cellPD, 0)
end
for x=1,4 do
	table.insert(module.plasmaOutput, 0)
end
for x=1,4 do
	table.insert(module.cellTemp, CHAMBER_AMBIENT)
end
--MAIN
function  wait(sec)
	os.execute("sleep "..tostring(sec))
end
function cap(num, cap)
	if num>cap then
		num = cap
	end
	if num<0 then
		num = 0
	end
	return num
end
function getPiTempIncrease(num)
	return (module.piFuelInput[num]*PLASMA_COMBUSTION_POWER) + math.random(0-COMBUSTION_TEMP_RANGE, COMBUSTION_TEMP_RANGE)/100*module.piFuelInput[num]
end
function getFuelTempInfluence(num)
	return (PI_FUEL_TEMP/100)*module.piFuelInput[num]
end
function updatePiTemps()
	for x=1,4 do
		temp = 0
		for i,v in pairs(module.piTemp[x]) do
			temp = temp + v
		end
		temp = temp + module.combustionTemp[x]
		module.piTemp[x][6] = module.piTemp[x][5]
		module.piTemp[x][5] = module.piTemp[x][4]
		module.piTemp[x][4] = module.piTemp[x][3]
		module.piTemp[x][3] = module.piTemp[x][2]
		module.piTemp[x][2] = module.piTemp[x][1]
		module.piTemp[x][1] = temp/7
	end
end
function updateCombustionTemps()
	for x=1,4 do
		module.combustionTemp[x] = module.piTemp[x][1] + getPiTempIncrease(x)
		if module.combustionTemp[x]>COMBUSTION_TEMP then
			module.combustionTemp[x] = (module.combustionTemp[x] + COMBUSTION_TEMP)/2
		end
	end
end
function updatePlamaOutput()
	for x=1,4 do
		module.plasmaOutput[x] = (module.piFuelInput[x]*PLASMA_COMBUSTION_POWER/9)/100
	end
end
function updateCellPlasma()
	for x=1,4 do
		--cell temp
		
		--cell pd
		module.cellPD[x] = module.cellPD[x] + module.plasmaOutput[x]/CELL_PLASMA_DIVIDER
		module.cellTemp[x] = cap(module.cellTemp[x]+(module.combustionTemp[x]*PLASMA_TO_CELL_DISIPATION), PLASMA_REACTION_TEMP)
		temp = module.cellTemp[x]
		if (0<temp) and (temp<PLASMA_IDEAL_DISAPATION_TEMP) then
			module.cellPD[x] -= (PLASMA_IDEAL_DISAPATION_TEMP-temp)*PLASMA_DISIPATION_RATE
		elseif (PLASMA_IDEAL_DISAPATION_TEMP<temp) and (temp<PLASMA_CRITICAL_TEMP) then
			module.cellPD[x] -= PLASMA_DISIPATION_RATE
		elseif PLASMA_CRITICAL_TEMP<temp then
			--stop else from executing
		else
			module.cellPD[x] -= PLASMA_DISIPATION_RATE
		end
		module.cellPD[x] = cap(module.cellPD[x], 1)
	end
end
function piUpdate()
	updateCombustionTemps()
	updatePiTemps()
	updatePlamaOutput()
end
function cellUpdate()
	updateCellPlasma()
end
local d = script.Parent.data
local pi = d.PI
local c = d.Cells
function exportData()
	for x=1,4 do
		pi[x].temp.Value = module.piTemp[x][1]
		pi[x].fuelInput.Value = module.piFuelInput[x]
		pi[x].combustionTemp.Value = module.combustionTemp[x]
		pi[x].plasmaOutput.Value = module.plasmaOutput[x]
	end
	c["1"].Temp.Value = module.cellTemp[1]
	c["1"].PD.Value = module.cellPD[1]
end

module.update = function()
	piUpdate()
	cellUpdate()
	exportData()
end

return module
