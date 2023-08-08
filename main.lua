local tileImages = {}  -- Tabla para almacenar las imágenes de las baldosas
local tilesetBatch  -- SpriteBatch para dibujar las baldosas
local tileWidth = 50  -- Ancho de las baldosas
local tileHeight = 50  -- Alto de las baldosas

local tileMap = {
    {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
    {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
    {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
    {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
    {2, 2, 2, 2, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
    {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
    {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 1, 2, 2},
    {2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 2, 3, 1, 2, 2},
    {2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 2, 2},
    {2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 2, 1, 2, 2},
    {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 2, 2},
    {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 2},
    {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
    {2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 2, 2, 2, 1, 2, 2, 2},
    {2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 2, 2, 1, 2, 2},
}

local characterImage
local characterX
local characterY
local characterSpeed = 200
local rockImage
local rockX = 4
local rockY = 9
local rockWidth = 10
local rockHeight = 10

-- Función para verificar colisión entre dos rectángulos
function checkCollision(rect1, rect2)
    return rect1.x < rect2.x + rect2.width and
           rect2.x < rect1.x + rect1.width and
           rect1.y < rect2.y + rect2.height and
           rect2.y < rect1.y + rect1.height
end

function defineQuads(imageWidth, imageHeight, tileWidth, tileHeight)
    local quads = {}
    
    local columns = imageWidth / tileWidth
    local rows = imageHeight / tileHeight
    
    for y = 0, rows - 1 do
        for x = 0, columns - 1 do
            local quad = love.graphics.newQuad(x * tileWidth, y * tileHeight, tileWidth, tileHeight, imageWidth, imageHeight)
            table.insert(quads, quad)
        end
    end
    
    return quads
end

function love.load()
    -- Carga la imagen de la roca
    rockImage = love.graphics.newImage("assets/rock1.png")
    
    -- Carga una sola imagen para todas las baldosas
    local tilesetImage = love.graphics.newImage("assets/tilesheet.png")
    
    -- Define quads automáticamente
    local quads = defineQuads(tilesetImage:getWidth(), tilesetImage:getHeight(), tileWidth, tileHeight)
    
    -- Crea el SpriteBatch
    tilesetBatch = love.graphics.newSpriteBatch(tilesetImage, #tileMap * #tileMap[1])

    -- Llena el SpriteBatch con las baldosas del mapa utilizando los quads
    for y = 1, #tileMap do
        for x = 1, #tileMap[y] do
            local tile = tileMap[y][x]
            tilesetBatch:setColor(1, 1, 1, 1)
            tilesetBatch:add(quads[tile], (x - 1) * tileWidth, (y - 1) * tileHeight)
        end
    end

    tilesetBatch:flush()  -- Finaliza la creación del SpriteBatch
    
    -- Carga la imagen del personaje
    characterImage = love.graphics.newImage("assets/char1.png")

    -- Calcula la posición del personaje centrado en pantalla
    characterX = love.graphics.getWidth() / 2 - characterImage:getWidth() / 2
    characterY = love.graphics.getHeight() / 2 - characterImage:getHeight() / 2
end

function love.update(dt)
    local moveX, moveY = 0, 0
    
    if love.keyboard.isDown("w") then
        moveY = moveY - 1
    end
    if love.keyboard.isDown("s") then
        moveY = moveY + 1
    end
    if love.keyboard.isDown("a") then
        moveX = moveX - 1
    end
    if love.keyboard.isDown("d") then
        moveX = moveX + 1
    end
    
    -- Normaliza el vector de movimiento si es diagonal
    if moveX ~= 0 and moveY ~= 0 then
        local length = math.sqrt(moveX * moveX + moveY * moveY)
        moveX = moveX / length
        moveY = moveY / length
    end
    
    -- Actualiza la posición del personaje
    local newX = characterX + moveX * characterSpeed * dt
    local newY = characterY + moveY * characterSpeed * dt

    -- Verifica la colisión con la roca
    local characterRect = { x = newX, y = newY, width = characterImage:getWidth(), height = characterImage:getHeight() }
    local rockRect = { x = rockX, y = rockY, width = rockWidth, height = rockHeight }
    
    if not checkCollision(characterRect, rockRect) then
        characterX = newX
        characterY = newY
    end
end

function love.draw()
    -- Dibuja la roca en la posición y tamaño especificados
    love.graphics.draw(rockImage, rockX, rockY, 20, rockWidth / rockImage:getWidth(), rockHeight / rockImage:getHeight())

    love.graphics.draw(tilesetBatch)

    -- Dibuja el personaje centrado en pantalla
    love.graphics.draw(characterImage, characterX, characterY)
end
