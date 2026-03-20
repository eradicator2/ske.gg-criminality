local l_1=game:GetService("Players")
local l_2=game:GetService("TweenService")
local l_3=game:GetService("UserInputService")
local l_4=game:GetService("RunService")
local l_5=game:GetService("HttpService")
local l_6=game:GetService("TextService")
local l_7=game:GetService("CoreGui")
local l_8=l_1.LocalPlayer
local l_9=l_8:GetMouse()

local function vc()
    local v2="Font_"..tostring(math.random(10000,99999))
    local v24="Folder_"..tostring(math.random(10000,99999))
    if isfolder("UI_Fonts")then delfolder("UI_Fonts")end
    makefolder(v24)
    local v3=v24.."/"..v2..".ttf"
    local v4=v24.."/"..v2..".json"
    local v5=v24.."/"..v2..".rbxmx"
    if not isfile(v3)then
        local v8=pcall(function()
            local v9=request({Url="https://raw.githubusercontent.com/bluescan/proggyfonts/refs/heads/master/ProggyOriginal/ProggyClean.ttf",Method="GET"})
            if v9 and v9.Success then writefile(v3,v9.Body)return true end
            return false
        end)
        if not v8 then return Font.fromEnum(Enum.Font.Code)end
    end
    local v12=pcall(function()
        local v13=readfile(v3)
        local v14=game:GetService("TextService"):RegisterFontFaceAsync(v13,v2)
        return v14
    end)
    if v12 then return v12 end
    local v15=pcall(function()return Font.fromFilename(v3)end)
    if v15 then return v15 end
    local v16={name=v2,faces={{name="Regular",weight=400,style="Normal",assetId=getcustomasset(v3)}}}
    writefile(v4,game:GetService("HttpService"):JSONEncode(v16))
    local v17,v18=pcall(function()return Font.new(getcustomasset(v4))end)
    if v17 then return v18 end
    local v19=[[
<?xml version="1.0" encoding="utf-8"?>
<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">
<External>null</External>
<External>nil</External>
<Item class="FontFace" referent="RBX0">
<Properties>
<Content name="FontData">
<url>rbxasset://]]..v3..[[</url>
</Content>
<string name="Family">]]..v2..[[</string>
<token name="Style">0</token>
<token name="Weight">400</token>
</Properties>
</Item>
</roblox>]]
    writefile(v5,v19)
    return Font.fromEnum(Enum.Font.Code)
end
local l_26=vc()

local l_27={drawings={},hidden={},connections={},pointers={},began={},ended={},changed={},folders={main="splix",assets="splix/assets",configs="splix/configs"},shared={initialized=false,fps=0,ping=0}}
local l_28={accent=Color3.fromRGB(50,100,255),light_contrast=Color3.fromRGB(30,30,30),dark_contrast=Color3.fromRGB(20,20,20),outline=Color3.fromRGB(0,0,0),inline=Color3.fromRGB(50,50,50),textcolor=Color3.fromRGB(255,255,255),textborder=Color3.fromRGB(0,0,0),font=l_26,textsize=13}

local function l_29(l_30,l_31)
    local l_32=Instance.new(l_30)
    for l_33,l_34 in pairs(l_31)do
        l_32[l_33]=l_34
    end
    return l_32
end

local function l_35(l_36,l_37)
    local l_38=Vector2.new(0,0)
    local l_39=l_29("TextLabel",{
        Text=l_36,
        TextSize=l_37,
        FontFace=l_28.font,
        Visible=false,
        Parent=l_7
    })
    l_38=Vector2.new(l_39.TextBounds.X,l_39.TextBounds.Y)
    l_39:Destroy()
    return l_38
end

local function l_40()
    return Vector2.new(l_9.X, l_9.Y)
end

local function l_42(l_43,l_44)
    local l_45=l_44 or{}
    local l_46={(l_43[1]or 0)+(l_45[1]or 0),(l_43[2]or 0)+(l_45[2]or 0),(l_43[3]or 0)+(l_45[3]or 0),(l_43[4]or 0)+(l_45[4]or 0)}
    local l_47=l_40()
    return(l_47.x>=l_46[1]and l_47.x<=(l_46[1]+(l_46[3]-l_46[1])))and(l_47.y>=l_46[2]and l_47.y<=(l_46[2]+(l_46[4]-l_46[2])))
end

local function l_48()
    return workspace.CurrentCamera.ViewportSize
end

l_27.__index=l_27
local l_49={}
l_49.__index=l_49
local l_50={}
l_50.__index=l_50

function l_27:New(l_51)
    local l_52=l_51 or{}
    local l_53=l_52.name or l_52.Name or l_52.title or l_52.Title or"UI Library"
    local l_54=l_52.size or l_52.Size or Vector2.new(500,400)
    local l_55=l_52.accent or l_52.Accent or l_28.accent
    l_28.accent=l_55
    local l_56={pages={},isVisible=false,uibind=Enum.KeyCode.RightShift,currentPage=nil,dragging=false,drag=Vector2.new(0,0)}
    local l_57=l_29("ScreenGui",{Name="SplixUI",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Parent=l_7})
    local l_58=l_29("Frame",{Name="main_frame",Size=UDim2.new(0,l_54.X,0,l_54.Y),Position=UDim2.new(0.5,-l_54.X/2,0.5,-l_54.Y/2),BackgroundColor3=l_28.outline,BorderSizePixel=0,Parent=l_57})
    local l_59=l_29("Frame",{Name="frame_inline",Size=UDim2.new(1,-2,1,-2),Position=UDim2.new(0,1,0,1),BackgroundColor3=l_28.accent,BorderSizePixel=0,Parent=l_58})
    local l_60=l_29("Frame",{Name="inner_frame",Size=UDim2.new(1,-2,1,-2),Position=UDim2.new(0,1,0,1),BackgroundColor3=l_28.light_contrast,BorderSizePixel=0,Parent=l_59})
    local l_61=l_29("TextLabel",{Name="title",Text=l_53,TextSize=l_28.textsize,FontFace=l_28.font,TextColor3=l_28.textcolor,TextStrokeColor3=l_28.textborder,TextStrokeTransparency=0,Position=UDim2.new(0,4,0,2),Size=UDim2.new(1,-8,0,16),BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,Parent=l_60})
    local l_62=l_29("Frame",{Name="inner_frame_inline",Size=UDim2.new(1,-8,1,-22),Position=UDim2.new(0,4,0,18),BackgroundColor3=l_28.inline,BorderSizePixel=0,Parent=l_60})
    local l_63=l_29("Frame",{Name="inner_frame_inline2",Size=UDim2.new(1,-2,1,-2),Position=UDim2.new(0,1,0,1),BackgroundColor3=l_28.outline,BorderSizePixel=0,Parent=l_62})
    local l_64=l_29("Frame",{Name="back_frame",Size=UDim2.new(1,-2,1,-2),Position=UDim2.new(0,1,0,1),BackgroundColor3=l_28.dark_contrast,BorderSizePixel=0,Parent=l_63})
    
    local l_65=l_29("ScrollingFrame",{
        Name="tab_frame_inline",
        Size=UDim2.new(1,-8,1,-28),
        Position=UDim2.new(0,4,0,24),
        BackgroundColor3=l_28.outline,
        BorderSizePixel=0,
        ScrollBarThickness=4,
        ScrollBarImageColor3=l_28.accent,
        CanvasSize=UDim2.new(0,0,0,0),
        Parent=l_64
    })
    local l_66=l_29("Frame",{Name="tab_frame_inline2",Size=UDim2.new(1,-2,1,-2),Position=UDim2.new(0,1,0,1),BackgroundColor3=l_28.inline,BorderSizePixel=0,Parent=l_65})
    local l_67=l_29("Frame",{Name="tab_frame",Size=UDim2.new(1,-2,1,-2),Position=UDim2.new(0,1,0,1),BackgroundColor3=l_28.light_contrast,BorderSizePixel=0,Parent=l_66})
    local l_68=l_29("Frame",{Name="tab_holder",Size=UDim2.new(1,0,0,25),Position=UDim2.new(0,0,0,0),BackgroundTransparency=1,Parent=l_67})
    l_56.main_frame=l_58
    l_56.back_frame=l_64
    l_56.tab_frame=l_67
    l_56.tab_holder=l_68
    l_56.gui=l_57
    l_56.scroll_frame=l_65
    
    function l_56:Move(l_69)
        l_58.Position=UDim2.new(0,l_69.X,0,l_69.Y)
    end
    
    function l_56:Fade()
        l_56.isVisible=not l_56.isVisible
        l_58.Visible=l_56.isVisible
    end
    
    function l_56:UpdateScrollSize()
        if l_56.currentPage then
            local l_161=0
            for l_162,l_163 in pairs(l_56.currentPage.sections)do
                l_161=l_161+l_163.section_frame.Size.Y.Offset+5
            end
            l_65.CanvasSize=UDim2.new(0,0,0,l_161)
        end
    end
    
    l_3.InputBegan:Connect(function(l_70,l_71)
        if l_71 then return end
        if l_70.KeyCode==l_56.uibind then
            l_56:Fade()
        end
        if(l_70.UserInputType==Enum.UserInputType.MouseButton1 or l_70.UserInputType==Enum.UserInputType.Touch)and l_56.isVisible and l_42({l_58.AbsolutePosition.X,l_58.AbsolutePosition.Y,l_58.AbsolutePosition.X+l_58.AbsoluteSize.X,l_58.AbsolutePosition.Y+20})then
            local l_72=l_40()
            l_56.dragging=true
            l_56.drag=Vector2.new(l_72.X-l_58.AbsolutePosition.X,l_72.Y-l_58.AbsolutePosition.Y)
        end
    end)
    
    l_3.InputEnded:Connect(function(l_73,l_74)
        if l_74 then return end
        if(l_73.UserInputType==Enum.UserInputType.MouseButton1 or l_73.UserInputType==Enum.UserInputType.Touch)and l_56.dragging then
            l_56.dragging=false
        end
    end)
    
    l_3.InputChanged:Connect(function(l_75,l_76)
        if l_76 then return end
        if l_56.dragging and(l_75.UserInputType==Enum.UserInputType.MouseMovement or l_75.UserInputType==Enum.UserInputType.Touch)then
            local l_77=l_40()
            local l_78=l_48()
            local l_79=Vector2.new(math.clamp(l_77.X-l_56.drag.X,0,l_78.X-l_58.AbsoluteSize.X),math.clamp(l_77.Y-l_56.drag.Y,0,l_78.Y-l_58.AbsoluteSize.Y))
            l_56:Move(l_79)
        end
    end)
    
    return setmetatable(l_56,l_49)
end


function l_49:Page(l_80)
    local l_81 = l_80 or {}
    local l_82 = l_81.name or l_81.Name or l_81.title or l_81.Title or "New Page"
    local l_83 = self
    local l_84 = {open = false, sections = {}, window = l_83, name = l_82}

    local l_85 = l_29("TextButton", {
        Name = l_82.."Page",
        Text = l_82,
        TextSize = l_28.textsize,
        FontFace = l_28.font,
        TextColor3 = l_28.textcolor,
        BackgroundColor3 = l_28.dark_contrast,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 80, 0, 20),
        Position = UDim2.new(0, 10 + (#l_83.pages * 85), 0, 2),
        Parent = l_83.tab_holder
    })

    l_84.page_button = l_85
    l_83.pages[#l_83.pages + 1] = l_84

    function l_84:Show()
        for _, page in pairs(l_83.pages) do
            page.page_button.BackgroundColor3 = l_28.dark_contrast
            page.open = false
            for _, section in pairs(page.sections) do
                if section.section_frame then
                    section.section_frame.Visible = false
                end
            end
        end

        
        l_83.currentPage = l_84
        l_85.BackgroundColor3 = l_28.accent
        l_84.open = true

        
        for _, section in pairs(l_84.sections) do
            if section.section_frame then
                section.section_frame.Visible = true
            end
        end

        l_83:UpdateScrollSize()
    end

    l_85.MouseButton1Click:Connect(function()
        l_84:Show()
    end)

    if #l_83.pages == 1 then
        l_84:Show()
    end

    return setmetatable(l_84, l_49)
end
function l_49:Watermark(cfg)
    local opt = cfg or {}
    local txt = opt.text or "Splix UI"
    local win = self

    
    local wm_outline = l_29("Frame", {
        Name = "watermark_outline",
        BackgroundColor3 = l_28.outline,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 160, 0, 28),
        Position = UDim2.new(0, 6, 0, 6),
        Parent = win.gui
    })

    
    local wm_inline = l_29("Frame", {
        BackgroundColor3 = l_28.inline,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        Parent = wm_outline
    })

    
    local wm_inner = l_29("Frame", {
        BackgroundColor3 = l_28.light_contrast,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        Parent = wm_inline
    })


    local wm_line = l_29("Frame", {
        BackgroundColor3 = l_28.accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 0, 0),
        Parent = wm_inner
    })

    
    local wm_label = l_29("TextLabel", {
        Text = txt,
        TextSize = l_28.textsize + 1,
        FontFace = l_28.font,
        TextColor3 = l_28.textcolor,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Parent = wm_inner,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Name = "watermark_label"
    })

    
    local toggle = l_29("TextButton", {
        Name = "toggle_ui_button",
        Text = "Toggle UI",
        TextSize = l_28.textsize,
        FontFace = l_28.font,
        TextColor3 = l_28.textcolor,
        BackgroundColor3 = l_28.light_contrast,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 160, 0, 22),
        Position = UDim2.new(0, 6, 0, 36),
        Parent = win.gui  
    })

    toggle.MouseButton1Click:Connect(function()
        win.isVisible = not win.isVisible
        win.main_frame.Visible = win.isVisible
    end)

    return wm_label
end
function l_49:Section(l_90)
    local l_91 = l_90 or {}
    local l_92 = l_91.name or l_91.Name or l_91.title or l_91.Title or "New Section"
    local l_93 = l_91.side or "left"
    local l_94 = self.window
    local l_95 = self
    local l_96 = {window = l_94, page = l_95, currentAxis = 20, side = l_93}

    local l_97 = l_29("Frame", {
        Name = l_92.."Section",
        BackgroundColor3 = l_28.inline,
        BorderSizePixel = 0,
        Size = UDim2.new(0.5, -7, 0, 200),
        Position = l_93 == "right" and UDim2.new(0.5, 2, 0, 30) or UDim2.new(0, 5, 0, 30),
        Visible = l_95.open,
        Parent = l_94.scroll_frame
    })

    local l_98 = l_29("Frame", {
        Name = "section_outline",
        BackgroundColor3 = l_28.outline,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        Parent = l_97
    })

    local l_99 = l_29("Frame", {
        Name = "section_frame",
        BackgroundColor3 = l_28.dark_contrast,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        Parent = l_98
    })

    local l_100 = l_29("Frame", {
        Name = "section_accent",
        BackgroundColor3 = l_28.accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 0, 0),
        Parent = l_99
    })

    local l_101 = l_29("TextLabel", {
        Name = "section_title",
        Text = l_92,
        TextSize = l_28.textsize,
        FontFace = l_28.font,
        TextColor3 = l_28.textcolor,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 15),
        Position = UDim2.new(0, 3, 0, 3),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = l_99
    })

    l_96.section_frame = l_97
    l_95.sections[#l_95.sections + 1] = l_96

    function l_96:Update()
        local yPosition = 30
        for _, section in pairs(l_95.sections) do
            if section.side == l_93 then
                if section == l_96 then
                    break
                else
                    yPosition = yPosition + section.currentAxis + 25
                end
            end
        end

        l_97.Position = l_93 == "right" and UDim2.new(0.5, 2, 0, yPosition) or UDim2.new(0, 5, 0, yPosition)
        l_97.Size = UDim2.new(0.5, -7, 0, l_96.currentAxis + 25)

        l_94:UpdateScrollSize()
    end

    l_96:Update()
    return setmetatable(l_96, l_50)
end

function l_50:Label(l_167)
    local l_168=l_167 or{}
    local l_169=l_168.name or l_168.Name or l_168.title or l_168.Title or"Label"
    local l_170=l_168.middle or false
    local l_171=l_168.pointer or nil
    local l_172=self.window
    local l_173=self.page
    local l_174=self
    local l_175={axis=l_174.currentAxis}
    local l_176=l_29("TextLabel",{
        Name="label_title",
        Text=l_169,
        TextSize=l_28.textsize,
        FontFace=l_28.font,
        TextColor3=l_28.textcolor,
        BackgroundTransparency=1,
        Size=UDim2.new(1,-8,0,15),
        Position=UDim2.new(0,4,0,l_175.axis),
        TextXAlignment=l_170 and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
        Visible=l_173.open,
        Parent=l_174.section_frame
    })
    if l_171 then l_27.pointers[l_171]=l_175 end
    l_174.currentAxis=l_174.currentAxis+19
    l_174:Update()
    return l_175
end

function l_50:Button(l_177)
    local l_178=l_177 or{}
    local l_179=l_178.name or l_178.Name or l_178.title or l_178.Title or"Button"
    local l_180=l_178.callback or function()end
    local l_181=l_178.pointer or nil
    local l_182=self.window
    local l_183=self.page
    local l_184=self
    local l_185={axis=l_184.currentAxis}
    local l_186=l_29("TextButton",{
        Name="button_outline",
        Text="",
        BackgroundColor3=l_28.outline,
        BorderSizePixel=0,
        Size=UDim2.new(1,-8,0,20),
        Position=UDim2.new(0,4,0,l_185.axis),
        Visible=l_183.open,
        Parent=l_184.section_frame
    })
    local l_187=l_29("Frame",{
        Name="button_inline",
        BackgroundColor3=l_28.inline,
        BorderSizePixel=0,
        Size=UDim2.new(1,-2,1,-2),
        Position=UDim2.new(0,1,0,1),
        Visible=l_183.open,
        Parent=l_186
    })
    local l_188=l_29("TextButton",{
        Name="button_frame",
        Text=l_179,
        TextSize=l_28.textsize,
        FontFace=l_28.font,
        TextColor3=l_28.textcolor,
        BackgroundColor3=l_28.light_contrast,
        BorderSizePixel=0,
        Size=UDim2.new(1,-2,1,-2),
        Position=UDim2.new(0,1,0,1),
        Visible=l_183.open,
        Parent=l_187
    })
    l_188.MouseButton1Click:Connect(function()
        if l_182.isVisible and l_183.open then
            l_180()
        end
    end)
    if l_181 then l_27.pointers[l_181]=l_185 end
    l_184.currentAxis=l_184.currentAxis+24
    l_184:Update()
    return l_185
end

--[[
function l_50:Dropdown(l_189)
local l_190=l_189 or{}
local l_191=l_190.name or l_190.Name or l_190.title or l_190.Title or"Dropdown"
local l_192=l_190.options or l_190.Options or{"Option 1","Option 2","Option 3"}
local l_193=l_190.def or{}
local l_194=l_190.callback or function()end
local l_195=l_190.pointer or nil
local l_196=self.window
local l_197=self.page
local l_198=self
local l_199={open=false,selected=l_193,options=l_192,axis=l_198.currentAxis}

local function updateText()
if type(l_199.selected)~="table"then
l_199.selected={}
end
local txt=table.concat(l_199.selected,", ")
if#txt>30 then txt=string.sub(txt,1,27).."..."
end
return txt=="" and "Select..." or txt
end

local l_200=l_29("TextButton",{
Name="dropdown_outline",
Text="",
BackgroundColor3=l_28.outline,
BorderSizePixel=0,
Size=UDim2.new(1,-8,0,20),
Position=UDim2.new(0,4,0,l_199.axis),
Visible=l_197.open,
Parent=l_198.section_frame
})
local l_201=l_29("Frame",{
Name="dropdown_inline",
BackgroundColor3=l_28.inline,
BorderSizePixel=0,
Size=UDim2.new(1,-2,1,-2),
Position=UDim2.new(0,1,0,1),
Visible=l_197.open,
Parent=l_200
})
local l_202=l_29("TextButton",{
Name="dropdown_frame",
Text=updateText(),
TextSize=l_28.textsize,
FontFace=l_28.font,
TextColor3=l_28.textcolor,
BackgroundColor3=l_28.light_contrast,
BorderSizePixel=0,
Size=UDim2.new(1,-2,1,-2),
Position=UDim2.new(0,1,0,1),
Visible=l_197.open,
TextXAlignment=Enum.TextXAlignment.Left,
TextTruncate=Enum.TextTruncate.AtEnd,
Parent=l_201
})
local l_203=l_29("TextLabel",{
Name="dropdown_arrow",
Text="▼",
TextSize=l_28.textsize-2,
FontFace=l_28.font,
TextColor3=l_28.textcolor,
BackgroundTransparency=1,
Size=UDim2.new(0,15,1,0),
Position=UDim2.new(1,-17,0,0),
TextXAlignment=Enum.TextXAlignment.Center,
Visible=l_197.open,
Parent=l_202
})

function l_199:Get()
if type(l_199.selected)~="table"then
l_199.selected={}
end
return l_199.selected
end

function l_199:Set(vals)
if type(vals)~="table"then
vals={vals}
end
l_199.selected=vals
l_202.Text=updateText()
l_194(l_199.selected)
end

function l_199:ToggleOptions()
l_199.open=not l_199.open
if l_199.open then
local l_205=l_29("Frame",{
Name="dropdown_options",
BackgroundColor3=l_28.outline,
BorderSizePixel=0,
Size=UDim2.new(1,0,0,#l_192*20),
Position=UDim2.new(0,0,1,2),
Visible=true,
Parent=l_200
})
for l_206,l_207 in pairs(l_192)do
local isSel=false
if type(l_199.selected)=="table"then
for _,v in ipairs(l_199.selected)do if v==l_207 then isSel=true break end end
end
local l_208=l_29("TextButton",{
Name="option_"..l_207,
Text=l_207,
TextSize=l_28.textsize,
FontFace=l_28.font,
TextColor3=l_28.textcolor,
BackgroundColor3=isSel and l_28.accent or l_28.light_contrast,
BorderSizePixel=0,
Size=UDim2.new(1,0,0,20),
Position=UDim2.new(0,0,0,(l_206-1)*20),
Visible=true,
TextXAlignment=Enum.TextXAlignment.Left,
Parent=l_205
})
l_208.MouseButton1Click:Connect(function()
if type(l_199.selected)~="table"then
l_199.selected={}
end
local exists=false
for i,v in ipairs(l_199.selected)do
if v==l_207 then table.remove(l_199.selected,i) exists=true break end
end
if not exists then table.insert(l_199.selected,l_207) end
l_202.Text=updateText()
for _,btn in pairs(l_205:GetChildren())do
if btn:IsA("TextButton")then
local selectedNow=false
if type(l_199.selected)=="table"then
for _,s in ipairs(l_199.selected)do if s==btn.Text then selectedNow=true break end end
end
btn.BackgroundColor3=selectedNow and l_28.accent or l_28.light_contrast
end
end
l_194(l_199.selected)
end)
end
else
for _,child in pairs(l_200:GetChildren())do
if child.Name=="dropdown_options"then child:Destroy()end
end
end
end

l_202.MouseButton1Click:Connect(function()
if l_196.isVisible and l_197.open then
l_199:ToggleOptions()
end
end)

if l_195 then l_27.pointers[l_195]=l_199 end
l_198.currentAxis=l_198.currentAxis+24
l_198:Update()
return l_199
end
--]]
function l_50:Checkbox(l_102)
    local l_103=l_102 or{}
    local l_104=l_103.name or l_103.Name or l_103.title or l_103.Title or"Checkbox"
    local l_105=l_103.def or false
    local l_106=l_103.callback or function()end
    local l_107=l_103.pointer or nil
    local l_108=self.window
    local l_109=self.page
    local l_110=self
    local l_111={current=l_105,axis=l_110.currentAxis}
    local l_112=l_29("TextButton",{
        Name="checkbox_button",
        BackgroundTransparency=1,
        BorderSizePixel=0,
        Size=UDim2.new(1,0,0,15),
        Position=UDim2.new(0,0,0,l_111.axis),
        Visible=l_109.open,
        Parent=l_110.section_frame
    })
    local l_113=l_29("Frame",{
        Name="checkbox_outline",
        BackgroundColor3=l_28.outline,
        BorderSizePixel=0,
        Size=UDim2.new(0,15,0,15),
        Position=UDim2.new(0,4,0,0),
        Visible=l_109.open,
        Parent=l_112
    })
    local l_114=l_29("Frame",{
        Name="checkbox_inline",
        BackgroundColor3=l_28.inline,
        BorderSizePixel=0,
        Size=UDim2.new(1,-2,1,-2),
        Position=UDim2.new(0,1,0,1),
        Visible=l_109.open,
        Parent=l_113
    })
    local l_115=l_29("Frame",{
        Name="checkbox_frame",
        BackgroundColor3=l_111.current and l_28.accent or l_28.light_contrast,
        BorderSizePixel=0,
        Size=UDim2.new(1,-2,1,-2),
        Position=UDim2.new(0,1,0,1),
        Visible=l_109.open,
        Parent=l_114
    })
    local l_116=l_29("TextLabel",{
        Name="checkbox_title",
        Text=l_104,
        TextSize=l_28.textsize,
        FontFace=l_28.font,
        TextColor3=l_28.textcolor,
        BackgroundTransparency=1,
        Size=UDim2.new(1,-25,1,0),
        Position=UDim2.new(0,23,0,0),
        TextXAlignment=Enum.TextXAlignment.Left,
        Visible=l_109.open,
        Parent=l_112
    })
    
    function l_111:Get()return l_111.current end
    
    function l_111:Set(l_117)
        l_111.current=l_117
        l_115.BackgroundColor3=l_111.current and l_28.accent or l_28.light_contrast
        l_106(l_111.current)
    end
    
    l_112.MouseButton1Click:Connect(function()
        if l_108.isVisible and l_109.open then
            l_111:Set(not l_111.current)
        end
    end)
    
    if l_107 then l_27.pointers[l_107]=l_111 end
    l_110.currentAxis=l_110.currentAxis+19
    l_110:Update()
    return l_111
end

function l_50:Slider(l_118)
    local l_119=l_118 or{}
    local l_120=l_119.name or l_119.Name or l_119.title or l_119.Title or"Slider"
    local l_121=l_119.min or 0
    local l_122=l_119.max or 100
    local l_123=l_119.def or l_121
    local l_124=l_119.callback or function()end
    local l_125=l_119.pointer or nil
    local l_126=self.window
    local l_127=self.page
    local l_128=self
    local l_129={current=l_123,holding=false,axis=l_128.currentAxis}
    local l_130=l_29("TextButton",{
        Name="slider_button",
        BackgroundTransparency=1,
        BorderSizePixel=0,
        Size=UDim2.new(1,-8,0,20),
        Position=UDim2.new(0,4,0,l_129.axis),
        Visible=l_127.open,
        Parent=l_128.section_frame
    })
    local l_131=l_29("Frame",{
        Name="slider_outline",
        BackgroundColor3=l_28.outline,
        BorderSizePixel=0,
        Size=UDim2.new(1,0,1,0),
        Position=UDim2.new(0,0,0,0),
        Visible=l_127.open,
        Parent=l_130
    })
    local l_132=l_29("Frame",{
        Name="slider_inline",
        BackgroundColor3=l_28.inline,
        BorderSizePixel=0,
        Size=UDim2.new(1,-2,1,-2),
        Position=UDim2.new(0,1,0,1),
        Visible=l_127.open,
        Parent=l_131
    })
    local l_133=l_29("Frame",{
        Name="slider_frame",
        BackgroundColor3=l_28.light_contrast,
        BorderSizePixel=0,
        Size=UDim2.new(1,-2,1,-2),
        Position=UDim2.new(0,1,0,1),
        Visible=l_127.open,
        Parent=l_132
    })
    local l_134=l_29("Frame",{
        Name="slider_fill",
        BackgroundColor3=l_28.accent,
        BorderSizePixel=0,
        Size=UDim2.new((l_123-l_121)/(l_122-l_121),0,1,0),
        Position=UDim2.new(0,0,0,0),
        Visible=l_127.open,
        Parent=l_133
    })
    local l_135=l_29("TextLabel",{
        Name="slider_title",
        Text=l_120,
        TextSize=l_28.textsize,
        FontFace=l_28.font,
        TextColor3=l_28.textcolor,
        BackgroundTransparency=1,
        Size=UDim2.new(1,0,1,0),
        Position=UDim2.new(0,4,0,0),
        TextXAlignment=Enum.TextXAlignment.Left,
        Visible=l_127.open,
        Parent=l_131
    })
    local l_136=l_29("TextLabel",{
        Name="slider_value",
        Text=tostring(l_123),
        TextSize=l_28.textsize,
        FontFace=l_28.font,
        TextColor3=l_28.textcolor,
        BackgroundTransparency=1,
        Size=UDim2.new(0,30,1,0),
        Position=UDim2.new(1,-34,0,0),
        Visible=l_127.open,
        Parent=l_131
    })
    
    function l_129:UpdateValue(l_137)
        local l_138=math.clamp(l_137/l_133.AbsoluteSize.X,0,1)
        local l_139=math.floor(l_121+(l_122-l_121)*l_138)
        l_129.current=l_139
        l_134.Size=UDim2.new(l_138,0,1,0)
        l_136.Text=tostring(l_139)
        l_124(l_139)
    end
    
    l_130.MouseButton1Down:Connect(function()
        if l_126.isVisible and l_127.open then
            local l_140=l_40()
            if l_42({l_131.AbsolutePosition.X,l_131.AbsolutePosition.Y,l_131.AbsolutePosition.X+l_131.AbsoluteSize.X,l_131.AbsolutePosition.Y+l_131.AbsoluteSize.Y})then
                local l_141=l_140.X-l_133.AbsolutePosition.X
                l_129:UpdateValue(l_141)
                l_129.holding=true
            end
        end
    end)

    l_3.InputChanged:Connect(function(l_144,l_145)
        if l_145 then return end
        if l_129.holding and(l_144.UserInputType==Enum.UserInputType.MouseMovement or l_144.UserInputType==Enum.UserInputType.Touch)then
            local l_146=l_40()
            if l_42({l_131.AbsolutePosition.X,l_131.AbsolutePosition.Y,l_131.AbsolutePosition.X+l_131.AbsoluteSize.X,l_131.AbsolutePosition.Y+l_131.AbsoluteSize.Y})then
                local l_147=l_146.X-l_133.AbsolutePosition.X
                l_129:UpdateValue(l_147)
            end
        end
    end)
    
    l_3.InputEnded:Connect(function(l_148,l_149)
        if l_149 then return end
        if(l_148.UserInputType==Enum.UserInputType.MouseButton1 or l_148.UserInputType==Enum.UserInputType.Touch)and l_129.holding then
            l_129.holding=false
        end
    end)
    
    if l_125 then l_27.pointers[l_125]=l_129 end
    l_128.currentAxis=l_128.currentAxis+24
    l_128:Update()
    return l_129
end


function l_50:Dropdown(l_189)
local l_190=l_189 or{}
local l_191=l_190.name or l_190.Name or l_190.title or l_190.Title or"Dropdown"
local l_192=l_190.options or l_190.Options or{"Option 1","Option 2","Option 3"}
local l_193=l_190.def or{}
local l_194=l_190.callback or function()end
local l_195=l_190.pointer or nil
local l_196=self.window
local l_197=self.page
local l_198=self
local l_199={open=false,selected=l_193,options=l_192,axis=l_198.currentAxis}

local function updateText()
if type(l_199.selected)~="table"then
l_199.selected={}
end
local txt=table.concat(l_199.selected,", ")
if#txt>30 then txt=string.sub(txt,1,27).."..."
end
return txt=="" and "Select..." or txt
end

local l_200=l_29("TextButton",{
Name="dropdown_outline",
Text="",
BackgroundColor3=l_28.outline,
BorderSizePixel=0,
Size=UDim2.new(1,-8,0,20),
Position=UDim2.new(0,4,0,l_199.axis),
Visible=l_197.open,
Parent=l_198.section_frame
})
local l_201=l_29("Frame",{
Name="dropdown_inline",
BackgroundColor3=l_28.inline,
BorderSizePixel=0,
Size=UDim2.new(1,-2,1,-2),
Position=UDim2.new(0,1,0,1),
Visible=l_197.open,
Parent=l_200
})
local l_202=l_29("TextButton",{
Name="dropdown_frame",
Text=updateText(),
TextSize=l_28.textsize,
FontFace=l_28.font,
TextColor3=l_28.textcolor,
BackgroundColor3=l_28.light_contrast,
BorderSizePixel=0,
Size=UDim2.new(1,-2,1,-2),
Position=UDim2.new(0,1,0,1),
Visible=l_197.open,
TextXAlignment=Enum.TextXAlignment.Left,
TextTruncate=Enum.TextTruncate.AtEnd,
Parent=l_201
})
local l_203=l_29("TextLabel",{
Name="dropdown_arrow",
Text="▼",
TextSize=l_28.textsize-2,
FontFace=l_28.font,
TextColor3=l_28.textcolor,
BackgroundTransparency=1,
Size=UDim2.new(0,15,1,0),
Position=UDim2.new(1,-17,0,0),
TextXAlignment=Enum.TextXAlignment.Center,
Visible=l_197.open,
Parent=l_202
})

function l_199:Get()
if type(l_199.selected)~="table"then
l_199.selected={}
end
return l_199.selected
end

function l_199:Set(vals)
if type(vals)~="table"then
vals={vals}
end
l_199.selected=vals
l_202.Text=updateText()
l_194(l_199.selected)
end
function l_199:AddOptions(newOptions)
    if type(newOptions)~="table"then
        newOptions={newOptions}
    end
    for _,option in ipairs(newOptions)do
        if not table.find(l_199.options,option)then
            table.insert(l_199.options,option)
        end
    end
end

function l_199:UpdateOptions(newOptions)
    if type(newOptions)~="table"then
        newOptions={newOptions}
    end
    l_199.options=newOptions
end
function l_199:CloseOptions()
for _,child in pairs(l_196.gui:GetChildren())do
if child.Name=="dropdown_options_"..tostring(l_200)then child:Destroy()end
end
l_199.open=false
end

function l_199:ToggleOptions()
if l_199.open then
l_199:CloseOptions()
return
end

l_199.open=true

local l_205=l_29("Frame",{
Name="dropdown_options_"..tostring(l_200),
BackgroundColor3=l_28.outline,
BorderSizePixel=0,
Size=UDim2.new(0,l_200.AbsoluteSize.X,0,math.min(#l_192*20,120)),
Position=UDim2.new(0,l_200.AbsolutePosition.X,0,l_200.AbsolutePosition.Y+l_200.AbsoluteSize.Y),
ZIndex=100,
Parent=l_196.gui
})

local l_206_scrolling=l_29("ScrollingFrame",{
Name="options_scroll",
BackgroundColor3=l_28.light_contrast,
BorderSizePixel=0,
Size=UDim2.new(1,-2,1,-2),
Position=UDim2.new(0,1,0,1),
CanvasSize=UDim2.new(0,0,0,#l_192*20),
ScrollBarThickness=4,
ScrollBarImageColor3=l_28.accent,
ZIndex=101,
Parent=l_205
})

local closeConnection
closeConnection=l_3.InputBegan:Connect(function(input,gameProcessed)
if input.UserInputType==Enum.UserInputType.MouseButton1 then
local mousePos=l_40()
local absPos=l_205.AbsolutePosition
local absSize=l_205.AbsoluteSize

if not(mousePos.X>=absPos.X and mousePos.X<=absPos.X+absSize.X and
mousePos.Y>=absPos.Y and mousePos.Y<=absPos.Y+absSize.Y)then
l_199:CloseOptions()
if closeConnection then closeConnection:Disconnect()end
end
end
end)

for l_206,l_207 in pairs(l_192)do
local isSel=false
if type(l_199.selected)=="table"then
for _,v in ipairs(l_199.selected)do if v==l_207 then isSel=true break end end
end
local l_208=l_29("TextButton",{
Name="option_"..l_207,
Text=l_207,
TextSize=l_28.textsize,
FontFace=l_28.font,
TextColor3=l_28.textcolor,
BackgroundColor3=isSel and l_28.accent or l_28.light_contrast,
BorderSizePixel=0,
Size=UDim2.new(1,0,0,20),
Position=UDim2.new(0,0,0,(l_206-1)*20),
Visible=true,
ZIndex=102,
TextXAlignment=Enum.TextXAlignment.Left,
Parent=l_206_scrolling
})
l_208.MouseButton1Click:Connect(function()
if type(l_199.selected)~="table"then
l_199.selected={}
end
local exists=false
for i,v in ipairs(l_199.selected)do
if v==l_207 then table.remove(l_199.selected,i)exists=true break end
end
if not exists then table.insert(l_199.selected,l_207)end
l_202.Text=updateText()
for _,btn in pairs(l_206_scrolling:GetChildren())do
if btn:IsA("TextButton")then
local selectedNow=false
if type(l_199.selected)=="table"then
for _,s in ipairs(l_199.selected)do if s==btn.Text then selectedNow=true break end end
end
btn.BackgroundColor3=selectedNow and l_28.accent or l_28.light_contrast
end
end
l_194(l_199.selected)
end)
end
end

l_202.MouseButton1Click:Connect(function()
if l_196.isVisible and l_197.open then
l_199:ToggleOptions()
end
end)

if l_195 then l_27.pointers[l_195]=l_199 end
l_198.currentAxis=l_198.currentAxis+24
l_198:Update()
return l_199
end

function l_50:Colorpicker(l_cfg)
local l_cfg=l_cfg or{}
local l_name=l_cfg.name or l_cfg.Name or"colorpicker"
local l_def=l_cfg.def or Color3.fromRGB(255,255,255)
local l_transp=l_cfg.transparency or l_cfg.Transparency or 0
local l_callback=l_cfg.callback or function()end
local l_pointer=l_cfg.pointer or nil
local l_window=self.window
local l_page=self.page
local l_section=self
local l_cp={current={l_def,l_transp},open=false,axis=l_section.currentAxis}
local l_outline=l_29("Frame",{Name="cp_outline",BackgroundColor3=l_28.outline,BorderSizePixel=0,Size=UDim2.new(1,-8,0,20),Position=UDim2.new(0,4,0,l_cp.axis),Visible=l_page.open,Parent=l_section.section_frame})
local l_inline=l_29("Frame",{Name="cp_inline",BackgroundColor3=l_28.inline,BorderSizePixel=0,Size=UDim2.new(1,-2,1,-2),Position=UDim2.new(0,1,0,1),Visible=l_page.open,Parent=l_outline})
local l_frame=l_29("TextButton",{Name="cp_frame",Text=l_name,TextSize=l_28.textsize,FontFace=l_28.font,TextColor3=l_28.textcolor,BackgroundColor3=l_28.light_contrast,BorderSizePixel=0,Size=UDim2.new(1,-2,1,-2),Position=UDim2.new(0,1,0,1),Visible=l_page.open,Parent=l_inline,TextXAlignment=Enum.TextXAlignment.Left})
local l_preview=l_29("Frame",{Name="cp_preview",BackgroundColor3=l_def,Size=UDim2.new(0,18,0,18),Position=UDim2.new(1,-22,0,1),Visible=l_page.open,Parent=l_frame})
local l_arrow=l_29("TextLabel",{Name="cp_arrow",Text="▼",TextSize=l_28.textsize-2,FontFace=l_28.font,TextColor3=l_28.textcolor,BackgroundTransparency=1,Size=UDim2.new(0,15,1,0),Position=UDim2.new(1,-40,0,0),Visible=l_page.open,Parent=l_frame,TextXAlignment=Enum.TextXAlignment.Center})

function l_cp:Get()return{Color=l_cp.current[1],Transparency=l_cp.current[2]}end

function l_cp:Set(c,t)
if typeof(c)=="Color3"then l_cp.current[1]=c end
if type(t)=="number"then l_cp.current[2]=t end
l_preview.BackgroundColor3=l_cp.current[1]
l_preview.BackgroundTransparency=1-l_cp.current[2]
l_callback(l_cp.current[1],l_cp.current[2])
end

function l_cp:ClosePicker()
for i,v in pairs(l_window.gui:GetChildren())do
if v.Name=="cp_options_"..tostring(l_outline)then v:Destroy()end
end
l_cp.open=false
end

function l_cp:Toggle()
if l_cp.open then
l_cp:ClosePicker()
return
end
l_cp.open=true

local l_opts=l_29("Frame",{
Name="cp_options_"..tostring(l_outline),
BackgroundColor3=l_28.outline,
BorderSizePixel=0,
Size=UDim2.new(0,180,0,100),
Position=UDim2.new(0,l_outline.AbsolutePosition.X,0,l_outline.AbsolutePosition.Y+l_outline.AbsoluteSize.Y),
ZIndex=100,
Parent=l_window.gui
})

local closeConn
closeConn=l_3.InputBegan:Connect(function(input,gameProcessed)
if input.UserInputType==Enum.UserInputType.MouseButton1 then
local pos=l_40()
if not(pos.X>=l_opts.AbsolutePosition.X and pos.X<=l_opts.AbsolutePosition.X+l_opts.AbsoluteSize.X and
pos.Y>=l_opts.AbsolutePosition.Y and pos.Y<=l_opts.AbsolutePosition.Y+l_opts.AbsoluteSize.Y)then
l_cp:ClosePicker()
if closeConn then closeConn:Disconnect()end
end
end
end)

local presets={"#FF3B30","#FF9500","#FFCC00","#34C759","#5AC8FA","#007AFF","#5856D6","#FF2D55"}
for i,hex in pairs(presets)do
local r=tonumber("0x"..string.sub(hex,2,3))
local g=tonumber("0x"..string.sub(hex,4,5))
local b=tonumber("0x"..string.sub(hex,6,7))
local col=Color3.fromRGB(r,g,b)
local btn=l_29("TextButton",{Name="preset_"..i,Text="",BackgroundColor3=col,BorderSizePixel=0,Size=UDim2.new(0,20,0,20),Position=UDim2.new(0,4+(i-1)*24,0,4),Visible=true,ZIndex=101,Parent=l_opts})
btn.MouseButton1Click:Connect(function()
l_cp:Set(col,l_cp.current[2])
end)
end

local t_label=l_29("TextLabel",{Name="transp_label",Text="Transparency",TextSize=l_28.textsize,FontFace=l_28.font,TextColor3=l_28.textcolor,BackgroundTransparency=1,Size=UDim2.new(1,-8,0,14),Position=UDim2.new(0,4,0,44),Visible=true,ZIndex=101,Parent=l_opts,TextXAlignment=Enum.TextXAlignment.Left})
local minus=l_29("TextButton",{Name="minus",Text="-",TextSize=l_28.textsize,FontFace=l_28.font,TextColor3=l_28.textcolor,BackgroundColor3=l_28.light_contrast,BorderSizePixel=0,Size=UDim2.new(0,18,0,14),Position=UDim2.new(1,-60,0,44),Visible=true,ZIndex=101,Parent=l_opts})
local plus=l_29("TextButton",{Name="plus",Text="+",TextSize=l_28.textsize,FontFace=l_28.font,TextColor3=l_28.textcolor,BackgroundColor3=l_28.light_contrast,BorderSizePixel=0,Size=UDim2.new(0,18,0,14),Position=UDim2.new(1,-36,0,44),Visible=true,ZIndex=101,Parent=l_opts})
local val=l_29("TextLabel",{Name="val",Text=tostring(math.floor(l_cp.current[2]*100)).."%",TextSize=l_28.textsize,FontFace=l_28.font,TextColor3=l_28.textcolor,BackgroundTransparency=1,Size=UDim2.new(0,30,0,14),Position=UDim2.new(1,-92,0,44),Visible=true,ZIndex=101,Parent=l_opts,TextXAlignment=Enum.TextXAlignment.Right})

minus.MouseButton1Click:Connect(function()
l_cp.current[2]=math.clamp(l_cp.current[2]-0.05,0,1)
val.Text=tostring(math.floor(l_cp.current[2]*100)).."%"
l_preview.BackgroundTransparency=1-l_cp.current[2]
l_callback(l_cp.current[1],l_cp.current[2])
end)

plus.MouseButton1Click:Connect(function()
l_cp.current[2]=math.clamp(l_cp.current[2]+0.05,0,1)
val.Text=tostring(math.floor(l_cp.current[2]*100)).."%"
l_preview.BackgroundTransparency=1-l_cp.current[2]
l_callback(l_cp.current[1],l_cp.current[2])
end)
end

l_frame.MouseButton1Click:Connect(function()
if l_window.isVisible and l_page.open then
l_cp:Toggle()
end
end)

if l_pointer then l_27.pointers[l_pointer]=l_cp end
l_section.currentAxis=l_section.currentAxis+24
l_section:Update()
return l_cp
end
return l_27
