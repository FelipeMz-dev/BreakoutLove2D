# BreakoutLove2D 🎮

Un proyecto educativo que demuestra la implementación de **Programación Orientada a Objetos (POO)**, **Principios SOLID**, **Patrones de Diseño** y **Buena Arquitectura de Software** en el desarrollo de videojuegos con **Lua** y **Love2D**.

## 📋 Descripción del Proyecto

BreakoutLove2D es un reimplementación del clásico juego Breakout que sirve como vehículo para aprender y demostrar conceptos fundamentales de ingeniería de software aplicados específicamente al desarrollo de videojuegos.

A través de este proyecto, exploramos cómo estructurar código de juego de forma profesional, mantenible y escalable, siguiendo estándares de la industria.

---

## 🏗️ Arquitectura General

### Estructura de Directorios

```
BreakoutLove2D/
├── src/
│   ├── entities/        # Clases base para entidades del juego
│   ├── gameobjects/     # Implementaciones concretas (Ball, Paddle, Brick, etc.)
│   ├── systems/         # Sistemas de lógica de juego (Physics, Collision, Input)
│   ├── managers/        # Managers de estado, recursos, etc.
│   ├── utils/           # Funciones utilitarias y helpers
│   └── main.lua         # Punto de entrada
├── assets/              # Recursos del juego (sprites, sonidos, fuentes)
├── conf.lua             # Configuración de Love2D
└── main.lua             # Archivo principal
```

---

## 🎯 Principios SOLID Implementados

### **S - Single Responsibility Principle (SRP)**

Cada clase tiene una única razón para cambiar.

#### Ejemplo:
```lua
-- ✅ Correcto: Responsabilidad única
Ball = Class('Ball')
function Ball:initialize(x, y, radius, speed)
    self.x = x
    self.y = y
    self.radius = radius
    self.vx = speed
    self.vy = speed
end

function Ball:update(dt)
    -- Solo actualiza posición
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
end

-- ❌ Evitar: Múltiples responsabilidades
-- Ball no debe dibujar, detectar colisiones ni gestionar sonidos
```

- **Ball**: Solo gestiona posición y movimiento
- **CollisionSystem**: Maneja detección de colisiones
- **AudioManager**: Gestiona reproducción de sonidos
- **Renderer**: Encargado del renderizado

---

### **O - Open/Closed Principle (OCP)**

Abierto para extensión, cerrado para modificación.

#### Ejemplo:
```lua
-- Clase base extensible
GameObject = Class('GameObject')
function GameObject:initialize(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
end

function GameObject:update(dt) end
function GameObject:draw() end
function GameObject:onCollision(other) end

-- Extensiones sin modificar la clase base
Ball = Class('Ball', GameObject)
function Ball:update(dt)
    -- Implementación específica
end

Brick = Class('Brick', GameObject)
function Brick:update(dt)
    -- Implementación específica
end

Paddle = Class('Paddle', GameObject)
function Paddle:update(dt)
    -- Implementación específica
end
```

**Ventaja**: Agregar nuevos tipos de objetos sin modificar código existente.

---

### **L - Liskov Substitution Principle (LSP)**

Las subclases pueden reemplazar a sus clases base sin romper la funcionalidad.

```lua
-- Interfaz común
Entity = Class('Entity')
function Entity:update(dt) error("Debe implementarse") end

-- Implementaciones intercambiables
Ball:extend(Entity)
Paddle:extend(Entity)
Brick:extend(Entity)

-- Todas pueden usarse en el mismo contexto
for _, entity in ipairs(entities) do
    entity:update(dt)  -- Funciona para cualquier Entity
end
```

---

### **I - Interface Segregation Principle (ISP)**

Los clientes no deben depender de interfaces que no utilizan.

```lua
-- ✅ Interfaces segregadas
Drawable = {
    draw = function(self) end
}

Updatable = {
    update = function(self, dt) end
}

Collidable = {
    onCollision = function(self, other) end
}

-- Clases implementan solo lo que necesitan
Ball = Class('Ball')
function Ball:draw() end
function Ball:update(dt) end
function Ball:onCollision(other) end

-- ❌ Evitar: Interface monolítica que todo debe implementar
```

---

### **D - Dependency Inversion Principle (DIP)**

Depende de abstracciones, no de concreciones.

```lua
-- ✅ Inyección de dependencias
GameLoop = Class('GameLoop')
function GameLoop:initialize(inputSystem, physicsSystem, renderSystem)
    self.input = inputSystem
    self.physics = physicsSystem
    self.renderer = renderSystem
end

function GameLoop:update(dt)
    self.input:update(dt)
    self.physics:update(dt)
    self.renderer:draw()
end

-- En main.lua
local inputSystem = InputSystem:new()
local physicsSystem = PhysicsSystem:new()
local renderSystem = RenderSystem:new()
local game = GameLoop:new(inputSystem, physicsSystem, renderSystem)
```

---

## 🧩 Patrones de Diseño Implementados

### **1. Pattern - Observer**
Notificación de eventos sin acoplamiento directo.

```lua
EventManager = Class('EventManager')

function EventManager:new()
    local instance = {listeners = {}}
    return setmetatable(instance, {__index = EventManager})
end

function EventManager:subscribe(event, callback)
    if not self.listeners[event] then
        self.listeners[event] = {}
    end
    table.insert(self.listeners[event], callback)
end

function EventManager:emit(event, data)
    if self.listeners[event] then
        for _, callback in ipairs(self.listeners[event]) do
            callback(data)
        end
    end
end
```

---

### **2. Pattern - Singleton**
Instancia única de un gestor global.

```lua
AudioManager = Class('AudioManager')

local instance = nil

function AudioManager:getInstance()
    if instance == nil then
        instance = AudioManager:new()
    end
    return instance
end

function AudioManager:playSound(soundName)
    -- Reproducir sonido
end
```

---

### **3. Pattern - Factory**
Creación de objetos sin especificar sus clases exactas.

```lua
EntityFactory = Class('EntityFactory')

function EntityFactory:createBall(x, y)
    return Ball:new(x, y, 5, 100)
end

function EntityFactory:createPaddle(x, y)
    return Paddle:new(x, y, 80, 10)
end

function EntityFactory:createBrick(x, y, type)
    return Brick:new(x, y, 50, 15, type)
end
```

---

### **4. Pattern - Strategy**
Seleccionar algoritmos en tiempo de ejecución.

```lua
CollisionStrategy = Class('CollisionStrategy')

CircleCollisionStrategy = Class('CircleCollisionStrategy', CollisionStrategy)
function CircleCollisionStrategy:detect(obj1, obj2)
    -- Lógica de colisión circular
end

RectangleCollisionStrategy = Class('RectangleCollisionStrategy', CollisionStrategy)
function RectangleCollisionStrategy:detect(obj1, obj2)
    -- Lógica de colisión rectangular
end

CollisionSystem = Class('CollisionSystem')
function CollisionSystem:initialize(strategy)
    self.strategy = strategy
end

function CollisionSystem:checkCollision(obj1, obj2)
    return self.strategy:detect(obj1, obj2)
end
```

---

### **5. Pattern - State**
Cambiar comportamiento basado en estado.

```lua
GameState = Class('GameState')

IdleState = Class('IdleState', GameState)
function IdleState:update(game) end
function IdleState:draw(game) end

PlayingState = Class('PlayingState', GameState)
function PlayingState:update(game)
    -- Lógica de juego activo
end

PausedState = Class('PausedState', GameState)
function PausedState:update(game) end

GameManager = Class('GameManager')
function GameManager:changeState(newState)
    self.currentState = newState
end
```

---

## 📚 Conceptos POO Implementados

### **Encapsulación**
```lua
Ball = Class('Ball')
function Ball:initialize(x, y)
    self._x = x  -- Privado (por convención con _)
    self._y = y
    self._radius = 5
end

function Ball:getX() return self._x end
function Ball:setX(x) self._x = x end
```

### **Herencia**
```lua
GameObject = Class('GameObject')
Ball = Class('Ball', GameObject)  -- Ball hereda de GameObject
```

### **Polimorfismo**
```lua
function GameObject:update(dt) end
function Ball:update(dt)
    -- Implementación específica
end
```

### **Abstracción**
```lua
-- Clases base abstractas que definen contratos
PhysicsObject = Class('PhysicsObject')
function PhysicsObject:applyForce(fx, fy) 
    error("Debe implementarse en subclase")
end
```

---

## 🔄 Flujo de la Arquitectura

### Game Loop

```
┌─────────────────────────────────────────────┐
│          Love2D Main Loop                   │
└──────────────────┬──────────────────────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
   ┌────▼────┐         ┌─────▼─────┐
   │ update  │         │    draw   │
   └────┬────┘         └─────┬─────┘
        │                     │
   ┌────▼──────────┐    ┌────▼──────────┐
   │ InputSystem   │    │ RenderSystem  │
   │ update(dt)    │    │ draw()        │
   └────┬──────────┘    └────┬──────────┘
        │                     │
   ┌────▼──────────┐    ┌────▼──────────┐
   │PhysicsSystem  │    │EntityRenderer │
   │update(dt)     │    │drawEntities() │
   └────┬──────────┘    └────┬──────────┘
        │                     │
   ┌────▼──────────┐    ┌────▼──────────┐
   │Collision      │    │ Particles     │
   │Detection      │    │ Effects       │
   └───────────────┘    └───────────────┘
```

---

## 🛠️ Mejores Prácticas Implementadas

### **1. Composición sobre Herencia**
```lua
-- Preferir composición
Entity = Class('Entity')
function Entity:initialize()
    self.physics = PhysicsComponent:new()
    self.renderer = RenderComponent:new()
    self.collision = CollisionComponent:new()
end

-- En lugar de largas cadenas de herencia
```

### **2. Inversión de Control (IoC)**
```lua
-- Los sistemas se pasan por inyección
Game = Class('Game')
function Game:initialize(inputSystem, renderSystem, physicsSystem)
    self.input = inputSystem
    self.render = renderSystem
    self.physics = physicsSystem
end
```

### **3. Separación de Responsabilidades**
- **Entities**: Datos (posición, velocidad, etc.)
- **Systems**: Lógica (física, colisión, entrada)
- **Managers**: Coordinación global

### **4. Configuración Centralizada**
```lua
-- config.lua
Config = {
    WINDOW_WIDTH = 800,
    WINDOW_HEIGHT = 600,
    BALL_SPEED = 200,
    PADDLE_SPEED = 300,
    GRAVITY = 500
}
```

---

## 📖 Cómo Usar Este Proyecto

### Ejecutar
```bash
git clone https://github.com/FelipeMz-dev/BreakoutLove2D.git
cd BreakoutLove2D
love .
```

### Estructura de Aprendizaje
1. **Principiante**: Comprender la estructura básica
2. **Intermedio**: Analizar los patrones implementados
3. **Avanzado**: Extender el juego con nuevas características

---

## 🎓 Conceptos Clave a Estudiar

- [ ] Programación Orientada a Objetos en Lua
- [ ] Principios SOLID
- [ ] Patrones de Diseño (GoF)
- [ ] Arquitectura de Sistemas de Juegos (ECS)
- [ ] Entity-Component-System (ECS)
- [ ] Game Loop Architecture
- [ ] Manejo de Eventos
- [ ] Inyección de Dependencias

---

## 📚 Referencias Recomendadas

- **Game Programming Patterns** - Robert Nystrom
- **Refactoring: Improving the Design of Existing Code** - Martin Fowler
- **Clean Code** - Robert C. Martin
- **Design Patterns: Elements of Reusable Object-Oriented Software** - Gang of Four
- **LÖVE 2D Oficial Documentation**

---

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:
1. Fork el proyecto
2. Crea una rama para tu feature
3. Asegúrate de seguir los principios SOLID
4. Abre un Pull Request

---

## ✨ Desarrollado por

**FelipeMz-dev**

_"La arquitectura limpia hoy es la claridad del mañana"_
