﻿
TOOL.Category		= "Constraints"
TOOL.Name			= "Prop Mover"
TOOL.Command		= nil
TOOL.ConfigName		= ""
//TOOL.Tab = "서버툴"
TOOL.MenuColor = Color(0,220,0,255)
if ( CLIENT ) then
    language.Add( "Tool.mover.name", "Prop Mover" )
    --language.Add( "Tool.mover.desc", "Left Click = Select a prop , Shift + Left = Select a base point , Right = Grab axis , Shift + Right = Snap, R = Unselect" )
    language.Add( "Tool.mover.desc", "Allows precise prop placement, piggybacks off Precision Alignments functions." )
    language.Add( "Tool.mover.0", "Left: Select a prop, Shift+Left: Select a base point, Right: Grab axis, Shift+Right: Snap, R: Unselect" )
	JG = JG or {}
	JG.stools = JG.stools or {}
	JG.stools.loadedP = JG.stools.loadedP or {}
	JG.stools.loadedP.mover = JG.stools.loadedP.mover or false
	
	JG = JG or {}
	JG.stools = JG.stools or {}
	JG.stools.CP = JG.stools.CP or {}
	JG.stools.CP.mover = JG.stools.CP.mover or {}
	JG.stools.Data = JG.stools.Data or {}
	JG.stools.Data.mover = JG.stools.Data.mover or {}

	
end

if SERVER then
	util.AddNetworkString(TOOL.Name.. "_LeftClick")
	util.AddNetworkString(TOOL.Name .. "_RightClick")
	util.AddNetworkString(TOOL.Name .. "_R")
end

TOOL.enttbl = {}

TOOL.ClientConVar = {

[ "radius" ] = "500" ,
[ "vehpro" ] = 0 ,
[ "gmodpro" ] = 0 ,
[ "gwirepro" ] = 0 ,
[ "onlyparent" ] = 0 ,
[ "timer" ] = 3

}

TOOL.Ent = NULL
TOOL.BasePos = NULL
function TOOL:LeftClick( trace )
	
	if SERVER then 
		if game.SinglePlayer() == true then
			net.Start(self.Name .. "_LeftClick")
			net.Send(player.GetHumans()[1])
		end
		return true 
	end
	if self.Owner:KeyDown(IN_SPEED) then
		if PA_funcs and PA_funcs.point_global( PA_selected_point ) == false then
			JG.stools.Data.mover.BasePos = trace.HitPos
		else
			JG.stools.Data.mover.BasePos = PA_funcs.point_global( PA_selected_point ).origin
		end
		-- JG.stools.CP.mover.proper[1]:SetValue(JG.stools.Data.mover.BasePos)
	else
		JG.stools.Data.mover.Ent = trace.Entity:IsValid() and not trace.Entity:IsNPC() and not trace.Entity:IsPlayer() and not trace.Entity:IsWorld() and trace.Entity or NULL
		if JG.stools.Data.mover.Ent != NULL then
			-- JG.stools.CP.mover.proper[2]:SetValue(tostring(JG.stools.Data.mover.Ent))
			JG.stools.CP.mover.DAdjustableModelPanel[1]:SetModel(JG.stools.Data.mover.Ent:GetModel())
			JG.stools.CP.mover.DLabel[1]:SetText(JG.stools.Data.mover.Ent:GetModel())
			JG.stools.Data.mover.Ent:SetRenderMode(1)
		end
		
	end
	return true
end

TOOL.lat = {pos = Vector() , 
lopos = Vector() , 
act = false , 
ang = Angle() , 
laang = Angle() , 
angdir = Vector(),
val1 = Vector()
}
TOOL.Time = CurTime()
TOOL.Leng = 0
TOOL.Axis = false
TOOL.Copy = false
function TOOL:IntersectRayWithPlane(planepoint,norm,line,linenormal)
	local linepoint = line*1
	local linepoint2 = linepoint+linenormal
	local x = norm:Dot(planepoint-linepoint) / norm:Dot(linenormal)//linepoint2-linepoint))
	local vec = linepoint + x * linenormal
	return vec
end

local math = math
local gui = gui
local input = input

function TOOL:RightClick( trace )
	if SERVER then 
		if game.SinglePlayer() == true then
			net.Start(self.Name .. "_RightClick")
			net.Send(player.GetHumans()[1])
		end
		return true 
	end
	if JG.stools.Data.mover.Ent:IsValid() == false then return end
	if self.coordS > 0 or self.AngS > 0 then
		local World = {x = Vector(1,0,0) , y = Vector(0,-1,0) , z = Vector(0,0,1)}
		self.Hold = true
		if self.lat.act == false then
			self.lat.act = true
			self.lat.pos = JG.stools.Data.mover.BasePos == NULL and JG.stools.Data.mover.Ent:GetPos() or JG.stools.Data.mover.BasePos
			self.lat.pos1 = JG.stools.Data.mover.Ent:GetPos()
			self.lat.mainpos = JG.stools.Data.mover.Ent:GetPos()
			self.lat.ang = JG.stools.Data.mover.Ent:GetAngles()
			if self.coordS > 0 then
				//timer.Start("SendData_Inf")
			elseif self.AngS >0 then
				local amount, dir = Vector() , Vector()
				if JG.stools.Data.mover.WL == false then
					if self.AngS == 1 then
						dir = JG.stools.Data.mover.Ent:GetForward()
						amount = self:IntersectRayWithPlane(self.lat.pos , dir , self.Owner:EyePos() , self.Owner:EyeAngles():Forward())
					elseif self.AngS == 2 then
						dir = JG.stools.Data.mover.Ent:GetRight()
						amount = self:IntersectRayWithPlane(self.lat.pos , dir , self.Owner:EyePos() , self.Owner:EyeAngles():Forward())
					elseif self.AngS == 3 then
						dir = JG.stools.Data.mover.Ent:GetUp()
						amount = self:IntersectRayWithPlane(self.lat.pos , dir , self.Owner:EyePos() , self.Owner:EyeAngles():Forward())
					end
				else
					if self.AngS == 1 then
						dir = World.x
						amount = self:IntersectRayWithPlane(self.lat.pos , dir , self.Owner:EyePos() , self.Owner:EyeAngles():Forward())
					elseif self.AngS == 2 then
						dir = World.y
						amount = self:IntersectRayWithPlane(self.lat.pos , dir , self.Owner:EyePos() , self.Owner:EyeAngles():Forward())
					elseif self.AngS == 3 then
						dir = World.z
						amount = self:IntersectRayWithPlane(self.lat.pos , dir , self.Owner:EyePos() , self.Owner:EyeAngles():Forward())
					end
				end
					amount = (amount - self.lat.pos):GetNormalized()
					local val1 = amount:Angle()
					val1:Normalize()
					val1 = val1:Right():Dot(dir)
					self.lat.val1 = val1 > 0 and 1 or -1
					self.lat.angdir = amount + Vector()
					self.lat.planedir = dir + Vector()
			end
		end
		local Lalt = input.IsKeyDown(KEY_LALT)
		if self.coordS > 0 then
			-- //JG.stools.Data.mover.Ent:SetPos(trace.HitPos)
			-- if CurTime() > self.Time then
				-- self.Time = CurTime() + 0.15
				-- //RunConsoleCommand("movprop", unpack{self.coordS , self.AngS})
			-- end
			local vec = trace.HitPos - self.lat.pos
			local vec2
			local len
			local dir
			if JG.stools.Data.mover.WL == false then
				if self.coordS == 1 then
					dir = JG.stools.Data.mover.Ent:GetForward()
					vec = self:IntersectRayWithPlane(self.lat.pos + dir * self.dist, JG.stools.Data.mover.Ent:GetUp() , self.Owner:EyePos() , self.Owner:EyeAngles():Forward())
				elseif self.coordS == 2 then
					dir = JG.stools.Data.mover.Ent:GetRight()
					vec = self:IntersectRayWithPlane(self.lat.pos + dir * self.dist , JG.stools.Data.mover.Ent:GetUp() , self.Owner:EyePos() , self.Owner:EyeAngles():Forward())
				elseif self.coordS == 3 then
					dir = JG.stools.Data.mover.Ent:GetUp()
					local val1 = (self.lat.pos - self.Owner:EyePos()):Angle()
					val1.p = 0
					val1 = val1:Forward()
					vec = self:IntersectRayWithPlane(self.lat.pos + dir * self.dist, val1, self.Owner:EyePos() , self.Owner:EyeAngles():Forward())
				end
			else
				if self.coordS == 1 then
					dir = World.x
					vec = self:IntersectRayWithPlane(self.lat.pos + dir * self.dist, World.z , self.Owner:EyePos() , self.Owner:EyeAngles():Forward())
				elseif self.coordS == 2 then
					dir = World.y
					vec = self:IntersectRayWithPlane(self.lat.pos + dir * self.dist ,World.z , self.Owner:EyePos() , self.Owner:EyeAngles():Forward())
				elseif self.coordS == 3 then
					dir = World.z
					local val1 = (self.lat.pos - self.Owner:EyePos()):Angle()
					val1.p = 0
					val1 = val1:Forward()
					vec = self:IntersectRayWithPlane(self.lat.pos + dir * self.dist, val1 , self.Owner:EyePos() , self.Owner:EyeAngles():Forward())
				end
			end
			len = self.lat.pos - vec
			vec = len:GetNormalized()
			len = len:Length()
			vec2 = vec:Dot(dir)
			
			local var3 = vec2 * len + self.dist
			if self.Owner:KeyDown(IN_SPEED) then
				local val = JG.stools.CP.mover.DNumSlider[2]:GetValue()
				local val2 = var3 < 0 and math.Round(var3 / val) * val or math.floor(var3 / val) * val
				JG.stools.Data.mover.Ent:SetPos( self.lat.pos - dir * val2)
				local val3 = self.coordS
				self.Leng = val3 ==2 and val2 or -val2
			else
				JG.stools.Data.mover.Ent:SetPos( self.lat.pos - dir * var3)
				local val3 = self.coordS
				self.Leng = -var3
			end
			
		elseif self.AngS > 0 then
			local amount, dir
			if JG.stools.Data.mover.WL == false then
				if self.AngS == 1 then
					dir = self.lat.ang:Forward() 
					amount = self:IntersectRayWithPlane(self.lat.pos , dir , self.Owner:EyePos() , self.Owner:EyeAngles():Forward())
				elseif self.AngS == 2 then
					dir = self.lat.ang:Right()
					amount = self:IntersectRayWithPlane(self.lat.pos , dir , self.Owner:EyePos() , self.Owner:EyeAngles():Forward())
				elseif self.AngS == 3 then
					dir = self.lat.ang:Up()
					amount = self:IntersectRayWithPlane(self.lat.pos , dir , self.Owner:EyePos() , self.Owner:EyeAngles():Forward())
				end
			else
				if self.AngS == 1 then
					dir = World.x
					amount = self:IntersectRayWithPlane(self.lat.pos , dir , self.Owner:EyePos() , self.Owner:EyeAngles():Forward())
				elseif self.AngS == 2 then
					dir = World.y
					amount = self:IntersectRayWithPlane(self.lat.pos , dir , self.Owner:EyePos() , self.Owner:EyeAngles():Forward())
				elseif self.AngS == 3 then
					dir = World.z
					amount = self:IntersectRayWithPlane(self.lat.pos , dir , self.Owner:EyePos() , self.Owner:EyeAngles():Forward())
				end
			end
			
			amount = (amount - self.lat.pos):GetNormalized()
			local dot = self.lat.angdir:DotProduct(amount) 
			//local p1 = math.sqrt(1 - (amount:Dot(self.lat.angdir)^2))
			local val1 = self.lat.angdir:Angle() + Angle()
			local p1 = val1 + Angle()
			p1:RotateAroundAxis(dir , 90)
			val1:Normalize()
			local val2 , val3
			local ang = self.lat.ang + Angle()
			ang:Normalize()
			local Lalt = Lalt
			if Lalt == false then
				-- if self.AngS == 3 then
					-- val2 = val1:Right():DotProduct(amount) 
				-- else
					-- val2 = val1:Up():DotProduct(amount)
				-- end
				-- val2 = math.acos(val1:Up():DotProduct(amount)) / math.pi * 180
				val2 = p1:Forward():Dot(amount)
				amount = (math.acos(dot)) * 180 / math.pi + 90 * math.pi / 180
				-- amount = math.asin(math.sqrt(1 - dot^2)) * 180 / math.pi
				amount = string.Left(amount,3) == "nan" and 0 or amount
				
				val3 = (val2 > 0 and 1 or -1)
				if self.Owner:KeyDown(IN_SPEED) then
					local val = JG.stools.CP.mover.DNumSlider[1]:GetValue()
					local mon = amount* val3
					mon = mon < 0 and math.ceil(mon / val) * val or math.floor(mon / val) * val
					ang:RotateAroundAxis(dir , mon )
				else
					ang:RotateAroundAxis(dir , amount* val3  )
				end
				self.amount = amount * val3
				
			else
			
				if self.Owner:KeyDown(IN_SPEED) then
					local val = JG.stools.CP.mover.DNumSlider[1]:GetValue()
					local val1 = self.AngS + 0
					local dir = dir
					local var0 = amount
					local val0 = self.lat.planedir:Angle()
					val0:Normalize()
					local toDeg = 180 / math.pi
					local amount = 0
					local var1 = self.lat.ang
					local var2 = math.acos(var1:Forward():Dot(-val0:Up())) * toDeg
					local var3 = val0:Right():Dot( var1:Forward())
					var3 = var3 < 0 and -1 or 1
					amount = var2 * var3
					amount = string.Left(amount,3) == "nan" and 0 or amount
					local var2 = math.acos(var0:Dot(-val0:Up())) * toDeg
					local var3 = val0:Right():Dot( var0)
					var3 = var3 < 0 and -1 or 1
					local var4 = var2 * var3
					-- if val1 < 3 then
						-- var4 = var4 < 0 and math.ceil(var4 / val) * val or math.floor(var4 / val) * val
					-- elseif val1 == 3 then
						-- var4 = var4 < 0 and math.ceil(var4 / val) * val or math.floor(var4 / val) * val
						var4 = math.floor(var4 / val) * val
					-- end
					local amount = amount - var4
					amount = string.Left(amount,3) == "nan" and 0 or amount
					ang:RotateAroundAxis(val0:Forward() , amount)				
					self.amount = var4		
				else
					local var0 = amount
					local val0 = self.lat.planedir:Angle() + Angle()
					val0:Normalize()
					local toDeg = 180 / math.pi
					-- local cosa = math.acos((-val0:Up()):Dot( self.lat.angdir )) * toDeg
					-- local val2 = val0:Right():Dot( self.lat.angdir)
					-- val2 = val2 < 0 and -1 or 1
					-- cosa = cosa * val2
					local amount = 0
					local var1 = self.lat.ang
					local var2 = math.acos(var1:Forward():Dot(-val0:Up())) * toDeg
					local var3 = val0:Right():Dot( var1:Forward())
					var3 = var3 < 0 and -1 or 1
					amount = var2 * var3
					self.amount1 = amount
					amount = string.Left(amount,3) == "nan" and 0 or amount
					local var2 = math.acos(var0:Dot(-val0:Up())) * toDeg
					local var3 = val0:Right():Dot( var0)
					var3 = var3 < 0 and -1 or 1
					local amount = amount - var2 * var3
					amount = string.Left(amount,3) == "nan" and 0 or amount
					ang:RotateAroundAxis(val0:Forward() , amount)				
					self.amount = -var2 * var3
				end
				
			end
			
			JG.stools.Data.mover.Ent:SetAngles(ang)
			local Lalt = Lalt
			if JG.stools.Data.mover.BasePos != NULL then //and Lalt == false then
			
				local vec = self.lat.mainpos - JG.stools.Data.mover.BasePos
				local len = vec:Length()
				local dir = vec:GetNormalized()
				//vec:Rotate(vec:Angle() - JG.stools.Data.mover.Ent:GetAngles())
				local ang = dir:Angle()
				ang:Normalize()
				local snap = self.UseSnap
				if JG.stools.Data.mover.WL == false then
					local mon
					if Lalt == false then
						if snap == true then
							local var1 = JG.stools.CP.mover.DNumSlider[1]:GetValue()
							mon = amount*(val2 > 0 and 1 or -1) //* self.lat.val1
							mon = mon < 0 and math.ceil(mon / var1) * var1 or math.floor(mon / var1) * var1
						else
							mon = amount* (val2 > 0 and 1 or -1) 
						end
					else
						if snap == true then
							local var1 = JG.stools.CP.mover.DNumSlider[1]:GetValue()
							mon = self.amount1 + self.amount
							mon = mon < 0 and math.ceil(mon / var1) * var1 or math.floor(mon / var1) * var1
							mon = - mon
						else
							mon = self.amount1 + self.amount
						end
					end
					if self.AngS == 1 then
						ang:RotateAroundAxis(JG.stools.Data.mover.Ent:GetForward() , mon )
					elseif self.AngS == 2 then
						ang:RotateAroundAxis(JG.stools.Data.mover.Ent:GetRight() , mon )
					elseif self.AngS == 3 then
						ang:RotateAroundAxis(JG.stools.Data.mover.Ent:GetUp() , mon )
					end
				elseif JG.stools.Data.mover.WL == true then
					local mon
					
					if Lalt == false then
						if snap == true then
							local var1 = JG.stools.CP.mover.DNumSlider[1]:GetValue()
							mon = amount * (val2 > 0 and 1 or -1)
							mon = mon < 0 and math.ceil(mon / var1) * var1 or math.floor(mon / var1) * var1
						else
							mon = amount * (val2 > 0 and 1 or -1)
						end
					else
						if snap == true then
							mon = -self.amount
						else
							mon = self.amount
						end
					end
					
					if self.AngS == 1 then
						ang:RotateAroundAxis(World.x , mon )
					elseif self.AngS == 2 then
						ang:RotateAroundAxis(World.y , mon )
					elseif self.AngS == 3 then
						ang:RotateAroundAxis(World.z , mon )
					end
				end
				JG.stools.Data.mover.Ent:SetPos(JG.stools.Data.mover.BasePos + ang:Forward() * len)
			end
			
		end
			self.lat.lopos = JG.stools.Data.mover.Ent:GetPos()
			self.lat.loang = JG.stools.Data.mover.Ent:GetAngles()
	else
		//timer.Stop("SendData_Inf")
	end
	return false
end
TOOL.amount = 0
TOOL.la = false
TOOL.first = false

TOOL.WL = false

function TOOL:Think()

	if SERVER then return end
	-- if game.SinglePlayer() then
		-- if g_ContextMenu:IsVisible() == false and gui.IsConsoleVisible() == false then
			-- if input.WasMousePressed( MOUSE_LEFT ) then
				-- local EP = EyePos()
				-- local tr = util.TraceLine({start = EP, endpos = EP + EyeAngles():Forward() * 50000 , filter = {self.Owner , self.Weapon, JG.stools.Data.mover.Ent} }) 
				-- self:LeftClick(tr)
			-- elseif input.WasMousePressed( MOUSE_RIGHT ) then
				-- local EP = EyePos()
				-- local tr = util.TraceLine({start = EP, endpos = EP + EyeAngles():Forward() * 50000 , filter = {self.Owner , self.Weapon, JG.stools.Data.mover.Ent} }) 
				-- self:RightClick(tr)
			-- elseif input.WasKeyPressed(KEY_R) then
				-- self:Reload()
			-- end
		-- end
	-- end
	if self.Hold then
		self.la = true
		local tr = util.TraceLine({start = self.Owner:EyePos() , endpos = self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * 50000 , filter = {self.Weapon  , self.Owner, JG.stools.Data.mover.Ent} }) 
		self:RightClick(tr)
	end
	if self.la == true and self.Hold == false then
		-- if self.coordS > 0 then
				-- net.Start("Inf_MoveP")
					-- net.WriteInt(self.coordS , 3)
					-- net.WriteInt(self.AngS , 3)
					-- net.WriteInt(JG.stools.Data.mover.Ent:EntIndex() , 12)
					-- net.WriteFloat(self.lat.lopos.x)
					-- net.WriteFloat(self.lat.lopos.y)
					-- net.WriteFloat(self.lat.lopos.z)
				-- net.SendToServer()
		-- elseif self.AngS > 0 then
				-- net.Start("Inf_MoveA")
					-- net.WriteInt(JG.stools.Data.mover.Ent:EntIndex() , 12)
					-- net.WriteFloat( self.lat.loang.p)
					-- net.WriteFloat( self.lat.loang.y)
					-- net.WriteFloat( self.lat.loang.r)
				-- net.SendToServer()
		-- end	
		if (self.lat.lopos - self.lat.pos):Length() < 5000 then
			net.Start("Inf_Move")
				net.WriteInt(self.coordS , 3)
				net.WriteInt(self.AngS , 3)
				net.WriteInt((JG.stools.Data.mover.Copy == true and 1 or 0) , 2)
				net.WriteInt(JG.stools.Data.mover.Ent:EntIndex() , 12)
				net.WriteVector(self.lat.lopos)
				net.WriteAngle(self.lat.loang)
				net.WriteVector(self.lat.pos1)
				net.WriteAngle(self.lat.ang)
			net.SendToServer()
			GAMEMODE:AddNotify("Successfully Sent",NOTIFY_HINT , 5)
			surface.PlaySound( "buttons/button15.wav" )
		else
			-- net.Start("Inf_Move")
				-- net.WriteInt(self.coordS , 3)
				-- net.WriteInt(self.AngS , 3)
				-- net.WriteInt(0x0. , 1)
				-- net.WriteInt(JG.stools.Data.mover.Ent:EntIndex() , 12)
				-- net.WriteFloat(self.lat.pos.x)
				-- net.WriteFloat(self.lat.pos.y)
				-- net.WriteFloat(self.lat.pos.z)
				-- net.WriteFloat( self.lat.ang.p)
				-- net.WriteFloat( self.lat.ang.y)
				-- net.WriteFloat( self.lat.ang.r)
			-- net.SendToServer()
			GAMEMODE:AddNotify("Failed : Abonormal Pos",NOTIFY_ERROR , 5)
			surface.PlaySound( "buttons/button10.wav" )
		end
		self.la = false
		self.lat.act = false
	end
	if self.first == false then
		net.Receive(self.Name.."_LeftClick" , function(leng , ply) 
			local EP , EA= EyePos() , EyeAngles()
			local forward = EA:Forward()
			local tr = util.TraceLine({start = EP , endpos = EP + forward * 50000 , filter = LocalPlayer()}) 
			self:LeftClick(tr)
		end)		
		
		net.Receive(self.Name.."_RightClick" , function(leng , ply) 
			local EP , EA= EyePos() , EyeAngles()
			local forward = EA:Forward()
			local tr = util.TraceLine({start = EP , endpos = EP + forward * 50000 , filter = LocalPlayer()}) 
			self:RightClick(tr)
		end)		
		
		net.Receive(self.Name.."_R" , function(leng , ply) 
			local EP , EA= EyePos() , EyeAngles()
			local forward = EA:Forward()
			local tr = util.TraceLine({start = EP , endpos = EP + forward * 50000 , filter = LocalPlayer()}) 
			self:Reload(tr)
		end)
		concommand.Add("mover_reloadui", function()
			self.first = false
			JG.stools.loadedP.mover = false
		end)
		self.first = true
		self.ratio = ScrW() / ScrH()
		if JG.stools.loadedP.mover == false then
			self.panel = controlpanel.Get("mover")
			if self.panel:GetInitialized() == false or  (g_SpawnMenu:IsVisible() == false and g_ContextMenu:IsVisible() == false) then 
				timer.Simple(0.5, function() 
					RunConsoleCommand("mover_reloadui") 
				end) 
				
				return 
			end

			self.panel:Clear()
			JG.stools.Data.mover = { Ent = NULL , BasePos = NULL , WL = false , Lat = NULL , la = false , Copy = false}
			-- for k,v in pairs(self.CP) do
				-- if type(v) == "table" then
					-- for i,o in pairs(v) do
						-- if o:IsValid() then
							-- if o.Remove then
								-- o:Remove()
							-- end
						-- end
					-- end
				-- else
					-- if v:IsValid() then
						-- if v.Remove then
							-- v:Remove()
						-- end
					-- end
				-- end
			-- end
			
			for k,v in pairs(self.panel:GetChildren()) do
				if v == self.panel then continue end
				local x,y = v:GetPos()
				local w,h = v:GetSize()
				if x == 0 and y == 0 and h == 20 then continue end
				if v.IsValid and v:IsValid() then
					v:Remove()
				end
			end
			-- JG.stools.CP.mover.proper = vgui.Create("DProperties" )
			-- JG.stools.CP.mover.proper:SetSize(300 ,150)
			-- self.panel:AddItem(JG.stools.CP.mover.proper)
			-- local t = JG.stools.CP.mover.proper
			-- t[1] = t:CreateRow( "Info", "BasePos" )
			-- t[1]:Setup("VectorColor")
			-- t[1]:SetValue(Vector())
			-- t[2] = t:CreateRow( "Info" , "Entity" )
			-- t[2]:Setup("Generic")
			-- t[2]:SetValue("Nope")
			
			JG.stools.CP.mover.DComboBox = {}
			local t = JG.stools.CP.mover.DComboBox
			t[1] = vgui.Create("DComboBox", self.panel)
			t[1]:SetPos( 10, 100 )
			t[1]:SetSize( 90, 25 )
			t[1]:SetValue( "Local" ) 
			t[1]:AddChoice( "World" )
			t[1]:AddChoice( "Local" )
			t[1].OnSelect = function( panel, index, value, data )
				if index == 2 then
					JG.stools.Data.mover.WL = false
				else
					JG.stools.Data.mover.WL = true
				end
			end
			
			JG.stools.CP.mover.DCheckBox = {}
			local t = JG.stools.CP.mover.DCheckBox
			t[1] = vgui.Create("DCheckBoxLabel" , self.panel)
			t[1]:SetPos(10,135)
			t[1]:SetSize(130,20)
			t[1]:SetText("Rotate - Point")
			t[1]:SetToolTip("Uses Axis function from Precision Alignment.\nYou may rotate props by grabbing axis.")
			t[1].Label:SetTextColor(Color(255,0,0,255))
			t[1].OnChange = function(panel , a)
				JG.stools.Data.mover.Axis = a
				if a == true then
					panel:SetText("Rotate - Axis")
					panel.Label:SetTextColor(Color(0,0,255,255))
				else
					panel:SetText("Rotate - Point")
					panel.Label:SetTextColor(Color(255,0,0,255))
				end
			end
			
			t[2] = vgui.Create("DCheckBoxLabel" , self.panel)
			t[2]:SetPos(10,285)
			t[2]:SetSize(130,20)
			t[2]:SetText("Copy - DeActive")
			t[2].Label:SetTextColor(Color(255,0,0,255))
			t[2]:SetToolTip("Each time you move props,\nduplicates the prop on original position.")
			t[2].OnChange = function(panel , a)
				JG.stools.Data.mover.Copy = a
				if a == true then
					panel:SetText("Copy - Active")
					panel.Label:SetTextColor(Color(0,255,0,255))
				else
					panel:SetText("Copy - DeActive")
					panel.Label:SetTextColor(Color(255,0,0,255))
				end
			end
			
			
			JG.stools.CP.mover.Binder = {}
			local t = JG.stools.CP.mover.Binder
			t[1] = vgui.Create("DBinder",self.panel)
			t[1]:SetSize(90, 40)
			t[1]:SetPos(10 , 160)

			JG.stools.CP.mover.Buttons = {}
			local t= JG.stools.CP.mover.Buttons
			t[1] = vgui.Create("DButton",self.panel)
			t[1]:SetPos(10 , 200)
			t[1]:SetSize(90,40)
			t[1]:SetText("Reset BasePos")
			t[1].DoClick = function(a)
				JG.stools.Data.mover.BasePos = NULL
				-- JG.stools.CP.mover.proper[1]:SetValue(Vector())
				//a:SetText(JG.stools.CP.mover.Binder[1]:GetValue())
			end
			
			local t= JG.stools.CP.mover.Buttons
			t[2] = vgui.Create("DButton",self.panel)
			t[2]:SetPos(10 , 240)
			t[2]:SetSize(90,40)
			t[2]:SetText("Reset Ent Info")
			t[2].DoClick = function(a)
				JG.stools.Data.mover.Ent = NULL
				-- JG.stools.CP.mover.proper[2]:SetValue("Nothing")
				//a:SetText(JG.stools.CP.mover.Binder[1]:GetValue())
			end
			
			JG.stools.CP.mover.DNumSlider = {}
			local t = JG.stools.CP.mover.DNumSlider
			t[1] = vgui.Create("DNumSlider", self.panel)
			t[1]:SetPos(10,300)
			t[1]:SetText("Snap Amount Deg")
			t[1]:SetSize(240,30)
			t[1].Label:SetSize(90)
			t[1].Label:SetDark(1)
			t[1]:SetDecimals(1)
			t[1]:SetMax(90)
			t[1]:SetMin(0)
			t[1]:SetValue(45)
			t[1].Paint = function(a)
				local x,y = self.panel:GetSize()
				draw.RoundedBox( 3, 0, 0, 100, 100, Color(255,255,255,100) )
			end
			
			local t = JG.stools.CP.mover.DNumSlider
			t[2] = vgui.Create("DNumSlider", self.panel)
			t[2]:SetPos(10,330)
			t[2]:SetText("Snap Amount Pos")
			t[2]:SetSize(240,30)
			t[2].Label:SetSize(90)
			t[2].Label:SetTextColor(Color(0,0,0,255))
			t[2]:SetDecimals(1)
			t[2]:SetMax(100)
			t[2]:SetMin(0)
			t[2]:SetValue(50)
			t[2].Paint = function(a)
				local x,y = self.panel:GetSize()
				draw.RoundedBox( 3, 0, 0, 100, 100, Color(255,255,255,100) )
			end
			
			JG.stools.CP.mover.DPanel = {}
			local t = JG.stools.CP.mover.DPanel
			t[1] = vgui.Create("DPanel" , self.panel)
			t[1]:SetPos(10,360)
			local val = self.panel:GetSize()
			t[1]:SetSize(val -20 , 300)
			t[1].Paint = function(a)
				local val = self.panel:GetSize()
				val = val - 20
				t[1]:SetSize(val , 300)
				JG.stools.CP.mover.DAdjustableModelPanel[1]:SetSize( val , val)
				local x,y = a:GetSize()
				//JG.stools.CP.mover.DLabel[1]:SetPos( x / 2 , 100)
				draw.RoundedBox( 6, 5, 5, val-10, y-10, Color(0,0,0,100) )
				draw.RoundedBox( 6, 0, 0, val, y, Color(0,0,0,100) )
			end
			
			JG.stools.CP.mover.DAdjustableModelPanel = {}
			local t = JG.stools.CP.mover.DAdjustableModelPanel
			t[1] = vgui.Create("DModelPanel", JG.stools.CP.mover.DPanel[1])
			t[1]:SetPos(0,0)
			t[1]:SetSize(200,200)
			t[1]:SetLookAt( Vector( 0,0,0 ))
			t[1]:SetModel( "models/props_borealis/bluebarrel001.mdl" )
			-- t[1].Paint = function(a)
				-- local x = JG.stools.CP.mover.DPanel[1]:GetSize() - 100
				-- t[1]:SetSize(x , x)
			-- end
			
			JG.stools.CP.mover.DLabel = {}
			
			local t = JG.stools.CP.mover.DLabel
			t[1] = vgui.Create("DLabel", JG.stools.CP.mover.DPanel[1] )
			t[1]:SetPos(10,60)
			t[1]:SetSize(10,10)
			t[1]:SetText("Default")
			t[1]:SizeToContents()
			t[1]:SetDrawBackground(true)
			//t[1]:SetBackgroundColor(Color(255,255,255,255))
			//t[1]:SetDark(1)
			//function asdb()
			
			local params = {
			["$basetexture"] = "models/debug/debugwhite",
			["$ignorez"]     = "1"
			}
			self.Mat = CreateMaterial("JG_MoverMat","UnlitGeneric", params )
			hook.Add("PostDrawTranslucentRenderables" , "Mover_Render", function()
				local ent = JG.stools.Data.mover.Ent
				if ent == NULL then return end
				local wep = LocalPlayer():GetActiveWeapon()
				if wep:IsValid() == false then self.la = false self.Hold = false return end
				if wep:GetClass() != "gmod_tool" then self.la = false self.Hold = false return end
				if wep:GetMode() != "mover" then self.la = false self.Hold = false return end
				local tmp = HSVToColor(CurTime() * 50 % 360,1,1)
				local Mat = self.Mat
					render.SuppressEngineLighting( true )
					render.SetColorModulation(  tmp.r / 255 , tmp.g/255 , tmp.b / 255 )
					render.MaterialOverride( Mat )
					render.SetBlend(0.6)
					ent:DrawModel()
					render.MaterialOverride()
					render.SuppressEngineLighting( false )
			end)
			
			JG.stools.loadedP.mover = true
		end
	
	
	
	end
end

function TOOL:Deploy()

end

function TOOL:Holster()

end
if SERVER then


	util.AddNetworkString("Inf_MoveP")
	util.AddNetworkString("Inf_MoveA")
	util.AddNetworkString("Inf_Move")
	net.Receive("Inf_MoveP", function(len , ply)
		local coordS , AngS , Copy , EntInd , Vec = net.ReadInt(3) , net.ReadInt(3) , net.ReadInt(1), net.ReadInt(12) , Vector(net.ReadFloat(),net.ReadFloat(),net.ReadFloat())
		local ent = ents.GetByIndex(EntInd)
		ent:SetPos(Vec)
		local phys = ent:GetPhysicsObject() 
		if phys:IsValid() then
			phys:EnableMotion(false)
		end
	end)	
	net.Receive("Inf_Move", function(len , ply)
		local coordS , AngS ,Copy , EntInd , Vec = net.ReadInt(3) , net.ReadInt(3) , net.ReadInt(2) , net.ReadInt(12) , net.ReadVector()
		local ang = net.ReadAngle()
		local ent = ents.GetByIndex(EntInd)
		local pos1 , ang1 = net.ReadVector(), net.ReadAngle()
		if ent:IsValid() then
			
			if math.abs(Vec.x) > 30000 or  math.abs(Vec.y) > 30000 or math.abs(Vec.z) > 30000 then
				Vec.x = math.Clamp(Vec.x , -30000 , 30000)
				Vec.y = math.Clamp(Vec.y , -30000 , 30000)
				Vec.z = math.Clamp(Vec.z , -30000 , 30000)
				print("nan Values")
			end
			local cop
			if Copy == 1 then
				local copT = duplicator.CopyEntTable(ent)
				cop = duplicator.CreateEntityFromTable(ply , copT)
				duplicator.DoGeneric(cop , copT)
			end
			if ent:GetParent() == NULL then
				ent:SetPos(Vec)
				ent:SetAngles(ang)
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					phys:EnableMotion(false)
					phys:Wake()
				end
			else
				local par = ent:GetParent()
				ent:SetParent()
				ent:SetPos(Vec)
				ent:SetAngles(ang)
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					phys:EnableMotion(false)
					phys:Wake()
				end
				ent:SetParent(par)
			end
			undo.Create("Mover")
				undo.SetPlayer(ply)
				undo.AddFunction(function(tbl , e , pos , ang) 
					if e:IsValid() == false then return end
					local par = e:GetParent()
					if par == NULL then
						e:SetPos(pos)
						e:SetAngles(ang)
						local phys = e:GetPhysicsObject()
						if phys:IsValid() then
							phys:EnableMotion(false)
							phys:Wake()
						end
					else
						e:SetParent()
						e:SetPos(pos)
						e:SetAngles(ang)
						local phys = e:GetPhysicsObject()
						if phys:IsValid() then
							phys:EnableMotion(false)
							phys:Wake()
						end
						e:SetParent(par)
					end
				end , ent , pos1 , ang1)
			undo.Finish()
			if Copy > 0 then
				undo.Create("Mover - Copied Entity")
					undo.SetPlayer(ply)
					undo.AddEntity(cop)
				undo.Finish()
			end
		else
			return
		end
	end)
	net.Receive("Inf_MoveA", function(len , ply)
		local ent , ang = ents.GetByIndex(net.ReadInt(12)) , Angle(net.ReadFloat(),net.ReadFloat(),net.ReadFloat())
		local phys = ent:GetPhysicsObject()
		ent:SetAngles(ang)
		if phys:IsValid() then
			phys:EnableMotion(false)
		end
	end)
	
end

function TOOL:Reload()
	if SERVER then 
		if game.SinglePlayer() == true then
			net.Start(self.Name .. "_R")
			net.Send(player.GetHumans()[1])
		end
		return true 
	end
	self.XYVal = {}
	self.AABB = {}
	JG.stools.Data.mover.Ent = NULL
	JG.stools.Data.mover.BasePos = NULL
	-- JG.stools.CP.mover.proper[1]:SetValue(Vector())
	-- JG.stools.CP.mover.proper[2]:SetValue("Nothing")
	JG.stools.CP.mover.DAdjustableModelPanel[1]:SetModel("models/props_borealis/bluebarrel001.mdl")
	JG.stools.CP.mover.DLabel[1]:SetText("Default")
	return true
end
TOOL.Lat = NULL
TOOL.AABB = {}
function TOOL:GetSign(a,b, c , d)

	local tmp = a + Vector()
	if b == 1 then
	elseif b == 2 then
		tmp.x , tmp.y , tmp.z = -tmp.x , tmp.y , tmp.z
	elseif b == 3 then
		tmp.x , tmp.y , tmp.z = -tmp.x , -tmp.y , tmp.z
	elseif b == 4 then
		tmp.x , tmp.y , tmp.z = tmp.x , -tmp.y , tmp.z
	elseif b == 5 then
		tmp.x , tmp.y , tmp.z = -tmp.x , -tmp.y , tmp.z
	elseif b == 6 then
		tmp.x , tmp.y , tmp.z = tmp.x , -tmp.y , tmp.z
	elseif b == 7 then
		tmp.x , tmp.y , tmp.z = tmp.x , tmp.y , tmp.z
	elseif b == 8 then
		tmp.x , tmp.y , tmp.z = -tmp.x , tmp.y , tmp.z
	end
	local val = JG.stools.Data.mover.Ent:LocalToWorld(tmp)
	return self:ToScreen2( val )
end

function TOOL:ToScreen2( v , v1)
	local cPos , cAng , cFov , scrW , scrH
	if v1 == nil then
	cPos , cAng , cFov , scrW , scrH = v - self.Owner:EyePos() , self.Owner:EyeAngles() , self.Owner:GetFOV() /180 * math.pi , ScrW() , ScrH()
	else
	cPos , cAng , cFov , scrW , scrH = v - self.Owner:EyePos() , self.Owner:EyeAngles() , self.Owner:GetFOV() /180 * math.pi , ScrW() , ScrH()
	end
	local vDir = cAng:Forward()
	vDir = cPos - vDir

	local d = 4 * scrH / ( 6 * math.tan( 0.5 * cFov ) )
	local fdp = cAng:Forward():Dot( vDir )

	if ( fdp == 0 ) then
	return 0, 0, false, false
	end

	local vProj = ( d / fdp ) * vDir

	local x = 0.5 * scrW + cAng:Right():Dot( vProj )
	local y = 0.5 * scrH - cAng:Up():Dot( vProj )
	if fdp < -0.1 then
		x , y = 30000, 30000
	end
	//return {x = x, y =  y, visible = ( 0 < x && x < scrW && 0 < y && y < scrH ) && fdp < 0, tmp = fdp > 0}
	return  {x = x, y =  y, visible = ( -300 < x && x < scrW +300 && -300 < y && y < scrH +300 ) && fdp > 0, tmp = fdp > 0}
end

TOOL.XYVal = {}
local function Vec2L(a,b)
	return math.sqrt((a.x - b.x) ^2 + (a.y - b.y)^2)
end
TOOL.colList = {x = Color(255, 0 , 0 , 255) , y = Color(0, 255 , 0 , 255)  , z = Color(0, 0 , 255 , 255)}
TOOL.AngS = 0
TOOL.coordS = 0 
TOOL.Hold = false
TOOL.UseSnap = false
function TOOL:Hud1()
	//draw.SimpleText("ABCDEFGHIJKLMNOPQRSTUVWXYZ" , "ChatFont", ScrW() / 2.0 , ScrH() / 2.0 , color_black , TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	//draw.SimpleText(tostring(JG.stools.Data.mover.Ent) , "ChatFont", ScrW() / 2.0 , ScrH() / 2.0+ 20 , color_black , TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	//draw.SimpleText(tostring(JG.stools.Data.mover.BasePos) , "ChatFont", ScrW() / 2.0 , ScrH() / 2.0+ 20 , color_black , TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	
	if self.Hold == true and self.Owner:KeyDown(IN_ATTACK2) == false then
		self.Hold = false
	end
	if self.Hold == false then self.lat.act = false end
	self.UseSnap = self.Owner:KeyDown(IN_SPEED)
	if JG.stools.Data.mover.Ent != NULL then
		local pos = JG.stools.Data.mover.BasePos == NULL and JG.stools.Data.mover.Ent:GetPos() or JG.stools.Data.mover.BasePos
		if self.Lat != JG.stools.Data.mover.Ent then
			self.AABB[1] , self.AABB[2] = JG.stools.Data.mover.Ent:WorldSpaceAABB()
			self.AABB[1] , self.AABB[2] = pos - self.AABB[1] , pos - self.AABB[2]
		end
		/*
		for i = 0 , 7 do
			local ind = i + 1
			self.XYVal[ind] = self:GetSign(self.AABB[math.floor(i/4)+1],ind , pos , JG.stools.Data.mover.Ent:GetAngles())
		end 
		*/
		local Ang = JG.stools.Data.mover.Ent:GetAngles()
		local Vec2 , Vec1 = {} , pos + Vector()
		self.dist = (Vec1 - self.Owner:EyePos()):Length()
		local Vec2_2  = self:ToScreen2(Vec1)
		local font = "ChatFont"
		local dot = {}
		if self.Hold == false then
			self.AngS = 0 
			self.coordS = 0
		end
		self.dist = math.min(self.dist , 600) / 6
		local World = {x = Vector(1,0,0) , y = Vector(0,-1,0) , z = Vector(0,0,1)}
		if JG.stools.Data.mover.WL == false then
			Vec2[1] = self:ToScreen2(Vec1 + Ang:Forward() * 2 * self.dist)
			dot[1] = self:ToScreen2(Vec1 + Ang:Forward() * self.dist)
			Vec2[2] = self:ToScreen2(Vec1 + Ang:Right() * 2 * self.dist)
			dot[2] = self:ToScreen2(Vec1 + Ang:Right() * self.dist)
			Vec2[3] = self:ToScreen2(Vec1 + Ang:Up() * 2 * self.dist)
			dot[3] = self:ToScreen2(Vec1 + Ang:Up() * self.dist)
		else
			Vec2[1] = self:ToScreen2(Vec1 + World.x * 2 * self.dist)
			dot[1] = self:ToScreen2(Vec1 + World.x * self.dist)
			Vec2[2] = self:ToScreen2(Vec1 + World.y * 2 * self.dist)
			dot[2] = self:ToScreen2(Vec1 + World.y * self.dist)
			Vec2[3] = self:ToScreen2(Vec1 + World.z * 2 * self.dist)
			dot[3] = self:ToScreen2(Vec1 + World.z * self.dist)
		end
		local List = {x = {} , y = {} , z = {} }
		local dis =   self.dist
		if JG.stools.Data.mover.WL == false then
			for i = 1 , 36 do
				local va = Ang + Angle()
				va:RotateAroundAxis( Ang:Forward() , 10 * i )
				List.x[i] = self:ToScreen2(Vec1+ va:Up() * 2 * dis)
				va = Ang + Angle()
				va:RotateAroundAxis( Ang:Right() , 10 * i )			
				List.y[i] = self:ToScreen2(Vec1+ va:Forward() * 2 * dis)
				va = Ang + Angle()
				va:RotateAroundAxis( Ang:Up() , 10 * i )			
				List.z[i] = self:ToScreen2(Vec1+ va:Forward() * 2 * dis)
			end
		else
			for i = 1 , 36 do
				local va = Angle()
				va:RotateAroundAxis( World.x , 10 * i )
				List.x[i] = self:ToScreen2(Vec1+ va:Up() * 2 * dis)
				va = Angle()
				va:RotateAroundAxis( World.y , 10 * i )			
				List.y[i] = self:ToScreen2(Vec1+ va:Forward() * 2 * dis)
				va = Angle()
				va:RotateAroundAxis( World.z , 10 * i )			
				List.z[i] = self:ToScreen2(Vec1+ va:Forward() * 2 * dis)
			end
		end
		
		if self.Hold then
			for i = 1 , 36 do
				local tmp = i > 35 and 1 or i+1
				if self.AngS == 1 then
					surface.SetDrawColor(self.colList.x )
					surface.DrawLine(List.x[i].x,List.x[i].y , List.x[tmp].x,List.x[tmp].y)		
				elseif self.AngS == 2 then
					surface.SetDrawColor(self.colList.y )
					surface.DrawLine(List.y[i].x,List.y[i].y , List.y[tmp].x,List.y[tmp].y)		
				elseif self.AngS == 3 then
					surface.SetDrawColor(self.colList.z )
					surface.DrawLine(List.z[i].x,List.z[i].y , List.z[tmp].x,List.z[tmp].y)			
				end
			end
		else
			for i = 1 , 36 do
				local tmp = i > 35 and 1 or i+1
				surface.SetDrawColor(self.colList.x )
				surface.DrawLine(List.x[i].x,List.x[i].y , List.x[tmp].x,List.x[tmp].y)			
				surface.SetDrawColor(self.colList.y )
				surface.DrawLine(List.y[i].x,List.y[i].y , List.y[tmp].x,List.y[tmp].y)			
				surface.SetDrawColor(self.colList.z )
				surface.DrawLine(List.z[i].x,List.z[i].y , List.z[tmp].x,List.z[tmp].y)
			end
		end
		
		if self.Hold then
			surface.SetDrawColor(Color(255,255,0,255))
			if JG.stools.Data.mover.WL == false then
				local val = self:ToScreen2(Vec1 + self.lat.angdir * dis*2)
				if self.UseSnap then
					if self.AngS == 1 then
						surface.DrawLine(Vec2_2.x , Vec2_2.y , val.x , val.y)
						local val2 = (self:IntersectRayWithPlane(self.lat.pos , JG.stools.Data.mover.Ent:GetForward() , self.Owner:EyePos() , self.Owner:EyeAngles():Forward()) - self.lat.pos)
						val = self:ToScreen2(Vec1+val2:GetNormalized() * 2 * dis)
						-- local val3= math.acos(self.lat.angdir:Dot(val2:GetNormalized())) * 180 / math.pi * self.lat.val1
						-- local p = JG.stools.CP.mover.DNumSlider[1]:GetValue()
						-- val3 = val3 < 0 and math.ceil(val3 / p) * p or math.floor(val3 / p ) * p
						-- val3 = val3 - p
						-- //val3 = (val3 > - p and val3 < p) and -p or val3
						-- local ang = self.lat.ang + Angle()
						-- ang:RotateAroundAxis(self.lat.ang:Forward() , val3)
						-- local o = self:ToScreen2(self.lat.pos+ ang:Right() * self.dist * 2)
						surface.SetDrawColor(Color(255,0,0,255))
						surface.DrawLine(Vec2_2.x , Vec2_2.y , val.x , val.y)
					elseif self.AngS == 2 then
						surface.DrawLine(Vec2_2.x , Vec2_2.y , val.x , val.y)
						val = self:ToScreen2(Vec1+(self:IntersectRayWithPlane(self.lat.pos , JG.stools.Data.mover.Ent:GetRight() , self.Owner:EyePos() , self.Owner:EyeAngles():Forward()) - self.lat.pos):GetNormalized() * 2 * dis)
						surface.SetDrawColor(Color(0,255,0,255))
						surface.DrawLine(Vec2_2.x , Vec2_2.y , val.x , val.y)
					elseif self.AngS == 3 then
						surface.DrawLine(Vec2_2.x , Vec2_2.y , val.x , val.y)
						val = self:ToScreen2(Vec1+(self:IntersectRayWithPlane(self.lat.pos , JG.stools.Data.mover.Ent:GetUp() , self.Owner:EyePos() , self.Owner:EyeAngles():Forward()) - self.lat.pos):GetNormalized() * 2 * dis)
						surface.SetDrawColor(Color(0,0,255,255))
						surface.DrawLine(Vec2_2.x , Vec2_2.y , val.x , val.y)
					end
				else
					if self.AngS == 1 then
						surface.DrawLine(Vec2_2.x , Vec2_2.y , val.x , val.y)
						val = self:ToScreen2(Vec1+(self:IntersectRayWithPlane(self.lat.pos , JG.stools.Data.mover.Ent:GetForward() , self.Owner:EyePos() , self.Owner:EyeAngles():Forward()) - self.lat.pos):GetNormalized() * 2 * dis)
						surface.SetDrawColor(Color(255,0,0,255))
						surface.DrawLine(Vec2_2.x , Vec2_2.y , val.x , val.y)
					elseif self.AngS == 2 then
						surface.DrawLine(Vec2_2.x , Vec2_2.y , val.x , val.y)
						val = self:ToScreen2(Vec1+(self:IntersectRayWithPlane(self.lat.pos , JG.stools.Data.mover.Ent:GetRight() , self.Owner:EyePos() , self.Owner:EyeAngles():Forward()) - self.lat.pos):GetNormalized() * 2 * dis)
						surface.SetDrawColor(Color(0,255,0,255))
						surface.DrawLine(Vec2_2.x , Vec2_2.y , val.x , val.y)
					elseif self.AngS == 3 then
						surface.DrawLine(Vec2_2.x , Vec2_2.y , val.x , val.y)
						val = self:ToScreen2(Vec1+(self:IntersectRayWithPlane(self.lat.pos , JG.stools.Data.mover.Ent:GetUp() , self.Owner:EyePos() , self.Owner:EyeAngles():Forward()) - self.lat.pos):GetNormalized() * 2 * dis)
						surface.SetDrawColor(Color(0,0,255,255))
						surface.DrawLine(Vec2_2.x , Vec2_2.y , val.x , val.y)
					end
				end
			else
					local val = self:ToScreen2(Vec1 + self.lat.angdir * dis*2)
				if self.AngS == 1 then
					surface.DrawLine(Vec2_2.x , Vec2_2.y , val.x , val.y)
					val = self:ToScreen2(Vec1+(self:IntersectRayWithPlane(self.lat.pos , World.x , self.Owner:EyePos() , self.Owner:EyeAngles():Forward()) - self.lat.pos):GetNormalized() * 2 * dis)
					surface.SetDrawColor(Color(255,0,0,255))
					surface.DrawLine(Vec2_2.x , Vec2_2.y , val.x , val.y)
				elseif self.AngS == 2 then
					surface.DrawLine(Vec2_2.x , Vec2_2.y , val.x , val.y)
					val = self:ToScreen2(Vec1+(self:IntersectRayWithPlane(self.lat.pos , World.y , self.Owner:EyePos() , self.Owner:EyeAngles():Forward()) - self.lat.pos):GetNormalized() * 2 * dis)
					surface.SetDrawColor(Color(0,255,0,255))
					surface.DrawLine(Vec2_2.x , Vec2_2.y , val.x , val.y)
				elseif self.AngS == 3 then
					surface.DrawLine(Vec2_2.x , Vec2_2.y , val.x , val.y)
					val = self:ToScreen2(Vec1+(self:IntersectRayWithPlane(self.lat.pos , World.z , self.Owner:EyePos() , self.Owner:EyeAngles():Forward()) - self.lat.pos):GetNormalized() * 2 * dis)
					surface.SetDrawColor(Color(0,0,255,255))
					surface.DrawLine(Vec2_2.x , Vec2_2.y , val.x , val.y)
				end
			end
			if self.AngS> 0 then
				local val = self:ToScreen2(Vec1 + self.lat.angdir * dis)
				local TAC = TEXT_ALIGN_CENTER
				if self.UseSnap then
					local val2 = JG.stools.CP.mover.DNumSlider[1]:GetValue()
					local mon = self.amount < 0 and math.ceil(self.amount / val2) * val2 or math.floor(self.amount / val2) * val2
					draw.SimpleText("Local Degree : " .. string.format("%.1f", mon) .. "º", font, val.x , val.y , Color(200 ,0,0,255) , TAC,TAC)
				else
					draw.SimpleText("Local Degree : " .. string.format("%.1f", self.amount) .. "º", font, val.x , val.y , Color(200 ,0,0,255) , TAC,TAC)
				end
			end
		end
		if !self.Hold then
			local mouse = { x =ScrW() / 2 , y = ScrH()/2}
			local entry = {9999 , 9999}
			for i = 1, 3 do
				local tmp = Vec2L(mouse,dot[i])
				if tmp < 13 then
					if entry[1] > tmp then
						entry[1] = tmp
						self.coordS  = i
					end
				end
			end
			
			local va = {30099,30099,30099}
			for i = 1 , 36 do
				local len = Vec2L(List.x[i] , mouse)
				if va[1] > len and len < 20 then
					va[1] = len
				end
				len = Vec2L(List.y[i] , mouse)
				if va[2] > len and len < 20 then
					va[2] = len
				end
				len = Vec2L(List.z[i] , mouse)
				if va[3] > len and len < 20 then
					va[3] = len
				end
			end
			for k,v in ipairs(va) do
				if entry[2] > v then 
					entry[2] = v
					self.AngS = k
				end
			end
			
			local a = 9999
			local t = 0
			for k,v in ipairs(entry) do
				if a > v then
					a = v
					t = k
				end
			end

			if t == 1 then self.AngS = 0 elseif t == 2 then self.coordS  = 0 end 
		end
		self.colList.x,self.colList.y,self.colList.z = 
		self.AngS ==1 and Color(255,255,0,255) or Color(255,0,0,255), 
		self.AngS == 2 and Color(255,255,0,255) or Color(0,255,0,255), 
		self.AngS == 3 and Color(255,255,0,255) or Color(0,0,255,255)
		local col
		if JG.stools.Data.mover.BasePos == NULL then
			if self.Hold then
				if JG.stools.Data.mover.WL == false then
					col= Color(255,255,0,255)
					local TAC = TEXT_ALIGN_CENTER
					if self.coordS == 1 then
						surface.SetDrawColor(col )
						surface.DrawLine(Vec2_2.x , Vec2_2.y , Vec2[1].x , Vec2[1].y)
						draw.SimpleText("+Forward Roll : " .. string.format("%.1f", Ang.r) .. "º", font, Vec2[1].x , Vec2[1].y , Color(200 ,0,0,255) , TAC,TAC)		
						surface.DrawCircle(dot[1].x , dot[1].y , 10 , col)
						draw.SimpleText("Length ( inch , m , cm) : " .. string.format("%.2f", self.Leng ) .. " , " .. string.format("%.2f", self.Leng *0.0254 ) .. " , " .. string.format("%.2f", self.Leng * 2.54 ), font, Vec2[1].x , Vec2[1].y + 30 , Color(2000 ,0,0,255) , TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
						local col = Color(0,255,255,255)
						local val1 = self:ToScreen2(self.lat.pos + JG.stools.Data.mover.Ent:GetForward() * self.dist)
						surface.DrawCircle(val1.x , val1.y , 20 , col)
					elseif self.coordS == 2 then
						surface.SetDrawColor(col)
						surface.DrawLine(Vec2_2.x , Vec2_2.y , Vec2[2].x , Vec2[2].y)
						draw.SimpleText("+Right Pitch : " .. string.format("%.1f", Ang.p) .. "º", font, Vec2[2].x , Vec2[2].y , Color(0 ,200,0,255) , TAC,TAC)	
						surface.DrawCircle(dot[2].x , dot[2].y , 10 , col)		
						draw.SimpleText("Length ( inch , m , cm) : " .. string.format("%.2f", self.Leng ) .. " , " .. string.format("%.2f", self.Leng *0.0254 ) .. " , " .. string.format("%.2f", self.Leng * 2.54 ), font, Vec2[2].x , Vec2[2].y + 30 , Color(0 ,200,0,255) , TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
						local col = Color(0,255,255,255)
						local val1 = self:ToScreen2(self.lat.pos + JG.stools.Data.mover.Ent:GetRight() * self.dist)
						surface.DrawCircle(val1.x , val1.y , 20 , col)
					elseif self.coordS == 3 then
						surface.SetDrawColor (col)
						surface.DrawLine(Vec2_2.x , Vec2_2.y , Vec2[3].x , Vec2[3].y)
						draw.SimpleText("+Up Yaw : " .. string.format("%.1f", Ang.y) .. "º", font, Vec2[3].x , Vec2[3].y , Color(0 ,0,200,255) , TAC,TAC)
						surface.DrawCircle(dot[3].x , dot[3].y , 10 , col)
						draw.SimpleText("Length ( inch , m , cm) : " .. string.format("%.2f", self.Leng ) .. " , " .. string.format("%.2f", self.Leng *0.0254 ) .. " , " .. string.format("%.2f", self.Leng * 2.54 ), font, Vec2[3].x , Vec2[3].y + 30, Color(0 ,0,200,255) , TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
						local col = Color(0,255,255,255)
						local val1 = self:ToScreen2(self.lat.pos + JG.stools.Data.mover.Ent:GetUp() * self.dist)
						surface.DrawCircle(val1.x , val1.y , 20 , col)
					end
				else
					col= Color(255,255,0,255)
					local TAC = TEXT_ALIGN_CENTER
					if self.coordS == 1 then
						surface.SetDrawColor(col )
						surface.DrawLine(Vec2_2.x , Vec2_2.y , Vec2[1].x , Vec2[1].y)
						draw.SimpleText("+Forward Roll", font, Vec2[1].x , Vec2[1].y , Color(200 ,0,0,255) , TAC,TAC)		
						surface.DrawCircle(dot[1].x , dot[1].y , 10 , col)
						draw.SimpleText("Length ( inch , m , cm) : " .. string.format("%.2f", self.Leng ) .. " , " .. string.format("%.2f", self.Leng *0.0254 ) .. " , " .. string.format("%.2f", self.Leng * 2.54 ), font, Vec2[1].x , Vec2[1].y + 30 , Color(2000 ,0,0,255) , TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
						local col = Color(0,255,255,255)
						local val1 = self:ToScreen2(self.lat.pos + JG.stools.Data.mover.Ent:GetForward() * self.dist)
						surface.DrawCircle(val1.x , val1.y , 20 , col)
					elseif self.coordS == 2 then
						surface.SetDrawColor(col)
						surface.DrawLine(Vec2_2.x , Vec2_2.y , Vec2[2].x , Vec2[2].y)
						draw.SimpleText("+Right Pitch", font, Vec2[2].x , Vec2[2].y , Color(0 ,200,0,255) , TAC,TAC)	
						surface.DrawCircle(dot[2].x , dot[2].y , 10 , col)		
						draw.SimpleText("Length ( inch , m , cm) : " .. string.format("%.2f", self.Leng ) .. " , " .. string.format("%.2f", self.Leng *0.0254 ) .. " , " .. string.format("%.2f", self.Leng * 2.54 ), font, Vec2[2].x , Vec2[2].y + 30 , Color(0 ,200,0,255) , TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
						local col = Color(0,255,255,255)
						local val1 = self:ToScreen2(self.lat.pos + JG.stools.Data.mover.Ent:GetRight() * self.dist)
						surface.DrawCircle(val1.x , val1.y , 20 , col)
					elseif self.coordS == 3 then
						surface.SetDrawColor (col)
						surface.DrawLine(Vec2_2.x , Vec2_2.y , Vec2[3].x , Vec2[3].y)
						draw.SimpleText("+Up Yaw", font, Vec2[3].x , Vec2[3].y , Color(0 ,0,200,255) , TAC,TAC)
						surface.DrawCircle(dot[3].x , dot[3].y , 10 , col)
						draw.SimpleText("Length ( inch , m , cm) : " .. string.format("%.2f", self.Leng ) .. " , " .. string.format("%.2f", self.Leng *0.0254 ) .. " , " .. string.format("%.2f", self.Leng * 2.54 ), font, Vec2[3].x , Vec2[3].y + 30, Color(0 ,0,200,255) , TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
						local col = Color(0,255,255,255)
						local val1 = self:ToScreen2(self.lat.pos + JG.stools.Data.mover.Ent:GetUp() * self.dist)
						surface.DrawCircle(val1.x , val1.y , 20 , col)
					end
				end
				//draw.SimpleText("" , Color(0 ,0,200,255) , TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			else
				if JG.stools.Data.mover.WL == false then
					local TAC = TEXT_ALIGN_CENTER
					surface.SetDrawColor(self.coordS  == 1 and Color(255,255,0,255) or Color(255,0,0,255) )
					surface.DrawLine(Vec2_2.x , Vec2_2.y , Vec2[1].x , Vec2[1].y)
					draw.SimpleText("+Forward Roll : " .. string.format("%.1f", Ang.r) .. "º", font, Vec2[1].x , Vec2[1].y , Color(200 ,0,0,255) , TAC , TAC)
					surface.SetDrawColor(self.coordS  == 2 and Color(255,255,0,255) or Color(0,255,0,255) )
					surface.DrawLine(Vec2_2.x , Vec2_2.y , Vec2[2].x , Vec2[2].y)
					draw.SimpleText("+Right Pitch : " .. string.format("%.1f", Ang.p) .. "º", font, Vec2[2].x , Vec2[2].y , Color(0 ,200,0,255) , TAC , TAC)
					surface.SetDrawColor(self.coordS  == 3 and Color(255,255,0,255) or Color(0,0,255,255) )
					surface.DrawLine(Vec2_2.x , Vec2_2.y , Vec2[3].x , Vec2[3].y)
					draw.SimpleText("+Up Yaw : " .. string.format("%.1f", Ang.y) .. "º", font, Vec2[3].x , Vec2[3].y , Color(0 ,0,200,255) , TAC , TAC)
					col = self.coordS  == 1 and Color(255,255,0,255) or Color(255 , 127 , 0 , 255)
					surface.DrawCircle(dot[1].x , dot[1].y , 10 , col)
					col = self.coordS  == 2 and Color(255,255,0,255) or Color(255 , 127 , 0 , 255)
					surface.DrawCircle(dot[2].x , dot[2].y , 10 , col)		
					col = self.coordS  == 3 and Color(255,255,0,255) or Color(255 , 127 , 0 , 255)
					surface.DrawCircle(dot[3].x , dot[3].y , 10 , col)
				else
					local TAC = TEXT_ALIGN_CENTER
					surface.SetDrawColor(self.coordS  == 1 and Color(255,255,0,255) or Color(255,0,0,255) )
					surface.DrawLine(Vec2_2.x , Vec2_2.y , Vec2[1].x , Vec2[1].y)
					draw.SimpleText("+Forward Roll", font, Vec2[1].x , Vec2[1].y , Color(200 ,0,0,255) , TAC , TAC)
					surface.SetDrawColor(self.coordS  == 2 and Color(255,255,0,255) or Color(0,255,0,255) )
					surface.DrawLine(Vec2_2.x , Vec2_2.y , Vec2[2].x , Vec2[2].y)
					draw.SimpleText("+Right Pitch", font, Vec2[2].x , Vec2[2].y , Color(0 ,200,0,255) , TAC , TAC)
					surface.SetDrawColor(self.coordS  == 3 and Color(255,255,0,255) or Color(0,0,255,255) )
					surface.DrawLine(Vec2_2.x , Vec2_2.y , Vec2[3].x , Vec2[3].y)
					draw.SimpleText("+Up Yaw", font, Vec2[3].x , Vec2[3].y , Color(0 ,0,200,255) , TAC , TAC)
					col = self.coordS  == 1 and Color(255,255,0,255) or Color(255 , 127 , 0 , 255)
					surface.DrawCircle(dot[1].x , dot[1].y , 10 , col)
					col = self.coordS  == 2 and Color(255,255,0,255) or Color(255 , 127 , 0 , 255)
					surface.DrawCircle(dot[2].x , dot[2].y , 10 , col)		
					col = self.coordS  == 3 and Color(255,255,0,255) or Color(255 , 127 , 0 , 255)
					surface.DrawCircle(dot[3].x , dot[3].y , 10 , col)
				end
			end
			local TAC = TEXT_ALIGN_CENTER
			draw.SimpleText(tostring(JG.stools.Data.mover.Ent:GetAngles()) , "ChatFont" , Vec2_2.x,Vec2_2.y , Color(255,0,255,255), TAC,TAC)
		end
	end
	
	//draw.SimpleText(table.Count(self.XYVal) , "ChatFont", ScrW() / 2.0 , ScrH() / 2.0+ 50 , color_black , TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	
	//draw.SimpleText(string.format("%.1f",self.amount), "ChatFont", ScrW() / 2.0 , ScrH() / 2.0+ 130 , color_black , TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	//draw.SimpleText(table.concat({self.coordS , self.AngS} , "   ") , "ChatFont", ScrW() / 2.0 , ScrH() / 2.0+ 90 , color_black , TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	
	//surface.SetDrawColor(Color(0,255,0,255) )
	
	/*
	if table.Count(self.XYVal) > 0 then

		surface.DrawLine(self.XYVal[1].x , self.XYVal[1].y , self.XYVal[2].x , self.XYVal[2].y)
		surface.DrawLine(self.XYVal[3].x , self.XYVal[3].y , self.XYVal[2].x , self.XYVal[2].y)
		surface.DrawLine(self.XYVal[1].x , self.XYVal[1].y , self.XYVal[4].x , self.XYVal[4].y)
		surface.DrawLine(self.XYVal[3].x , self.XYVal[3].y , self.XYVal[4].x , self.XYVal[4].y)
		
		surface.DrawLine(self.XYVal[5].x , self.XYVal[5].y , self.XYVal[6].x , self.XYVal[6].y)
		surface.DrawLine(self.XYVal[7].x , self.XYVal[7].y , self.XYVal[6].x , self.XYVal[6].y)
		surface.DrawLine(self.XYVal[5].x , self.XYVal[5].y , self.XYVal[8].x , self.XYVal[8].y)
		surface.DrawLine(self.XYVal[7].x , self.XYVal[7].y , self.XYVal[8].x , self.XYVal[8].y)
		
		surface.DrawLine(self.XYVal[1].x , self.XYVal[1].y , self.XYVal[5].x , self.XYVal[5].y)
		surface.DrawLine(self.XYVal[2].x , self.XYVal[2].y , self.XYVal[6].x , self.XYVal[6].y)
		surface.DrawLine(self.XYVal[3].x , self.XYVal[3].y , self.XYVal[7].x , self.XYVal[7].y)
		surface.DrawLine(self.XYVal[4].x , self.XYVal[4].y , self.XYVal[8].x , self.XYVal[8].y)

	end
	*/
	self.Lat = JG.stools.Data.mover.Ent
end

TOOL.ratio = 0
function TOOL:Hud2()
	local SW , SH = ScrW() , ScrH()
	local str , font , col = "" , "ChatFont" , Color(0,0,0,255)
	if self.UseSnap then
		col = Color(255,0,255,255)
		str = "Snap enabled"
	else
		col = Color(255,255,0,255)
		str = "Snap disabled"
	end
	local TAC = TEXT_ALIGN_CENTER
	draw.SimpleText(str , font , SW - 50*self.ratio , 150 * self.ratio , col , TAC,TAC )
	local str = ""
	str = "Right Click : "
	draw.SimpleText(str , font , SW - 100 * self.ratio , 150 * self.ratio , col , TAC ,TAC)
	
	local str , col = "" , col
	if self.UseSnap then
		col = Color(127,0,255,255)
		str = "Select a base point"
	else
		col = Color(255,127,0,255)
		str = "Select a prop"
	end
	local TAC = TAC
	draw.SimpleText(str , font , SW - 50 * self.ratio , 160 * self.ratio , col , TAC ,TAC)
	local str = ""
	str = "Left Click : "
	draw.SimpleText(str , font , SW - 100 * self.ratio , 160 * self.ratio , col , TAC ,TAC)
	
	
	-- draw.SimpleText(tostring(self.lat.angdir) , font , SW - 100 * self.ratio , 300 * self.ratio , col , TAC ,TAC)
	-- draw.SimpleText(tostring(self.lat.angdir:Angle()) , font , SW - 100 * self.ratio , 310 * self.ratio , col , TAC ,TAC)
	-- draw.SimpleText(tostring(self.lat.angdir:Angle():Up():Angle():Up()) , font , SW - 100 * self.ratio , 320 * self.ratio , col , TAC ,TAC)
	-- draw.SimpleText(tostring(self.lat.angdir:Angle():Up():Angle():Up():Angle()) , font , SW - 100 * self.ratio , 330 * self.ratio , col , TAC ,TAC)
end

function TOOL:Hud3()
	local str , SW , SH = "" , ScrW()  , ScrH() 
	local hSW , hSH = SW/2  , SH /2 
	local font , col = "ChatFont" , Color(200,0,0,240)
	local TAC = TEXT_ALIGN_CENTER
	if PA_funcs == nil then
		draw.SimpleText("Precision Alignment is not loaded!" , font , hSW * self.ratio , 100 * self.ratio , col  , TAC ,TAC)
		draw.SimpleText("Open Precision Alignment to enable full functionality." , font , hSW * self.ratio , 110 * self.ratio , col  , TAC ,TAC)
	else
		col = Color(0,200,0,220)
		draw.SimpleText("Precision Alignment is loaded." , font , hSW* self.ratio , 100 * self.ratio , col  , TAC ,TAC)
		local po , li = PA_selected_point , PA_selected_line
		local str = "Selected Point Stack Index : " .. po .. " -> " .. tostring(type(PA_funcs.point_global(po)) == "table")
		col = Color(220,0,0,220)
		draw.SimpleText(str , font , (hSW + 40) * self.ratio , hSH + 100 * self.ratio , col , TAC ,TAC)
		local str = "Selected Line Stack Index : " .. li .. " - > " .. tostring(type(PA_funcs.line_global(li)) == "table") // startpoint , endpoint
		col = Color(0,0,220,220)
		draw.SimpleText(str , font , (hSW + 40) * self.ratio , hSH + 110 * self.ratio , col , TAC ,TAC)
	end

end
function TOOL:DrawHUD()
	if JG.stools.loadedP.mover == false then return end
	self:Hud1()
	self:Hud2()
	self:Hud3()
end

function TOOL.BuildCPanel(cp)
	

end