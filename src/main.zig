const rl = @import("raylib");

const Rectangle = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,

    pub fn intersect(self: Rectangle, other: Rectangle) bool {
        return self.x < other.x + other.width and
            self.x + self.width > other.x and
            self.y < other.y + other.height and
            self.y + self.height > other.y;
    }
};

const GameConfig = struct {
    screenWidth: i32,
    screenHeight: i32,
    playerWidth: f32,
    playerHeight: f32,
    playerStartX: f32,
    playerStartY: f32,
    bulletWidth: f32,
    bulletHeight: f32,
    shieldStartX: f32,
    shieldY: f32,
    shieldWidth: f32,
    shieldHeight: f32,
    shieldSpacing: f32,
    invaderWidth: f32,
    invaderHeight: f32,
    invaderStartX: f32,
    invaderStartY: f32,
    invaderSpacingX: f32,
    invaderSpacingY: f32,
};

const Player = struct {
    position_x: f32,
    position_y: f32,
    height: f32,
    width: f32,
    speed: f32,

    pub fn init(
        position_x: f32,
        position_y: f32,
        width: f32,
        height: f32,
    ) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
            .speed = 5.0,
        };
    }

    pub fn update(self: *@This()) void {
        if (rl.isKeyDown(rl.KeyboardKey.right) or rl.isKeyDown(rl.KeyboardKey.l)) {
            self.position_x += self.speed;
        }
        if (rl.isKeyDown(rl.KeyboardKey.left) or rl.isKeyDown(rl.KeyboardKey.j)) {
            self.position_x -= self.speed;
        }
        if (self.position_x < 0) {
            self.position_x = 0;
        }
        if (self.position_x + self.width > @as(f32, @floatFromInt(rl.getScreenWidth()))) {
            self.position_x = @as(f32, @floatFromInt(rl.getScreenWidth())) - self.width;
        }
    }

    pub fn getRect(self: @This()) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }
    pub fn draw(self: @This()) void {
        rl.drawRectangle(
            @intFromFloat(self.position_x),
            @intFromFloat(self.position_y),
            @intFromFloat(self.width),
            @intFromFloat(self.height),
            rl.Color.blue,
        );
    }
};

const Bullet = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,
    active: bool,

    pub fn init(
        position_x: f32,
        position_y: f32,
        width: f32,
        height: f32,
    ) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
            .speed = 10.0,
            .active = false, // for object pooling: create a bunch of bullets and reuse them as needed
        };
    }

    pub fn update(self: *@This()) void {
        if (self.active) {
            self.position_y -= self.speed;
            if (self.position_y < 0) {
                self.active = false;
            }
        }
    }

    pub fn draw(self: @This()) void {
        if (self.active) {
            rl.drawRectangle(
                @intFromFloat(self.position_x),
                @intFromFloat(self.position_y),
                @intFromFloat(self.width),
                @intFromFloat(self.height),
                rl.Color.red,
            );
        }
    }

    pub fn getRect(self: @This()) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }
};

const Invader = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,
    isalive: bool,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
            .speed = 5.0,
            .isalive = true,
        };
    }

    pub fn update(self: *@This(), dx: f32, dy: f32) void {
        self.position_x += dx;
        self.position_y += dy;
    }

    pub fn draw(self: @This()) void {
        if (self.isalive) {
            rl.drawRectangle(
                @intFromFloat(self.position_x),
                @intFromFloat(self.position_y),
                @intFromFloat(self.width),
                @intFromFloat(self.height),
                rl.Color.green,
            );
        }
    }

    pub fn getRect(self: @This()) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }
};

const EnemyBullet = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,
    active: bool,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
            .speed = 5.0,
            .active = false, // for object pooling: create a bunch of bullets and reuse them as needed
        };
    }

    pub fn update(self: *@This(), screen_height: i32) void {
        if (self.active) {
            self.position_y += self.speed;
            if (self.position_y > @as(f32, @floatFromInt(screen_height))) {
                self.active = false;
            }
        }
    }

    pub fn draw(self: @This()) void {
        if (self.active) {
            rl.drawRectangle(
                @intFromFloat(self.position_x),
                @intFromFloat(self.position_y),
                @intFromFloat(self.width),
                @intFromFloat(self.height),
                rl.Color.yellow,
            );
        }
    }

    pub fn getRect(self: @This()) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }
};

const Shield = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    health: i32,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
            .health = 10,
        };
    }

    pub fn draw(self: @This()) void {
        if (self.health > 0) {
            const alpha = @as(u8, @intCast(@min(255, self.health * 25)));

            rl.drawRectangle(
                @intFromFloat(self.position_x),
                @intFromFloat(self.position_y),
                @intFromFloat(self.width),
                @intFromFloat(self.height),
                rl.Color{ .r = 0, .g = 255, .b = 255, .a = alpha },
            );
        }
    }

    pub fn getRect(self: @This()) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }
};

fn resetGame(
    player: *Player,
    bullets: []Bullet,
    enemy_bullets: []EnemyBullet,
    shields: []Shield,
    invaders: anytype,
    invader_direction: *f32,
    score: *i32,
    config: GameConfig,
) void {
    score.* = 0;
    player.* = Player.init(
        @as(f32, @floatFromInt(config.screenWidth)) / 2 - config.playerWidth / 2,
        @as(f32, @floatFromInt(config.screenHeight)) - 60.0,
        config.playerWidth,
        config.playerHeight,
    );

    for (bullets) |*bullet| {
        bullet.active = false;
    }
    for (enemy_bullets) |*bullet| {
        bullet.active = false;
    }
    for (shields, 0..) |*shield, i| {
        const x = config.shieldStartX + @as(f32, @floatFromInt(i)) * config.shieldSpacing;
        shield.* = Shield.init(
            x,
            config.shieldY,
            config.shieldWidth,
            config.shieldHeight,
        );
    }

    for (invaders, 0..) |*row, i| {
        for (row, 0..) |*invader, j| {
            const x = config.invaderStartX + @as(f32, @floatFromInt(j)) * config.invaderSpacingX;
            const y = config.invaderStartY + @as(f32, @floatFromInt(i)) * config.invaderSpacingY;
            invader.* = Invader.init(
                x,
                y,
                config.invaderWidth,
                config.invaderHeight,
            );
        }
    }
    invader_direction.* = 1.0;
}

pub fn main() !void {
    const screenWidth = 800;
    const screenHeight = 600;

    const playerWidth = 50.0;
    const playerHeight = 30.0;
    const playerStartX = @as(f32, @floatFromInt(screenWidth)) / 2 - playerWidth / 2;
    const playerStartY = @as(f32, @floatFromInt(screenHeight)) - 60.0;

    const maxBullets = 10;
    const bulletWidth = 4.0;
    const bulletHeight = 10.0;

    const invaderRows = 5;
    const invaderCols = 11;
    const invaderWidth = 40.0;
    const invaderHeight = 30.0;
    const invaderStartX = 100.0;
    const invaderStartY = 50.0;
    const invaderSpacingX = 60.0;
    const invaderSpacingY = 40.0;
    const invaderSpeed = 5.0;
    const invaderMoveDelay = 30;
    const invaderDropDistance = 30.0;

    const maxEnemyBullets = 20;
    const enemyShootDelay = 60;
    const enemyShootChance = 5;
    const shieldCount = 4;
    const shieldWidth = 80.0;
    const shieldHeight = 60.0;
    const shieldStartX = 150.0;
    const shieldY = 450.0;
    const shieldSpacing = 150.0;

    var game_over: bool = false;
    var game_won: bool = false;
    var invader_direction: f32 = 1.0;
    var move_timer: i32 = 0;
    var enemy_shoot_timer: i32 = 0;
    var score: i32 = 0;

    const config = GameConfig{
        .screenWidth = screenHeight,
        .screenHeight = screenHeight,
        .playerWidth = playerWidth,
        .playerHeight = playerHeight,
        .playerStartX = playerStartX,
        .playerStartY = playerStartY,
        .bulletWidth = bulletWidth,
        .bulletHeight = bulletHeight,
        .invaderHeight = invaderHeight,
        .invaderWidth = invaderWidth,
        .invaderSpacingX = invaderSpacingX,
        .invaderSpacingY = invaderSpacingY,
        .invaderStartX = invaderStartX,
        .invaderStartY = invaderStartY,
        .shieldWidth = shieldWidth,
        .shieldHeight = shieldHeight,
        .shieldStartX = shieldStartX,
        .shieldY = shieldY,
        .shieldSpacing = shieldSpacing,
    };

    // Game initialisation
    rl.initWindow(screenWidth, screenHeight, "Zig Invaders");
    defer rl.closeWindow();

    var player = Player.init(
        playerStartX,
        playerStartY,
        playerWidth,
        playerHeight,
    );

    var shields: [shieldCount]Shield = undefined;
    for (&shields, 0..) |*shield, i| {
        const x = shieldStartX + @as(f32, @floatFromInt(i)) * shieldSpacing;
        shield.* = Shield.init(
            x,
            shieldY,
            shieldWidth,
            shieldHeight,
        );
    }

    // bullets
    var bullets: [maxBullets]Bullet = undefined;
    for (&bullets) |*bullet| {
        bullet.* = Bullet.init(
            0,
            0,
            bulletWidth,
            bulletHeight,
        );
    }
    // bullets
    var enemy_bullets: [maxEnemyBullets]EnemyBullet = undefined;
    for (&enemy_bullets) |*enemybullet| {
        enemybullet.* = EnemyBullet.init(
            0,
            0,
            bulletWidth,
            bulletHeight,
        );
    }

    // invaders
    var invaders: [invaderRows][invaderCols]Invader = undefined;
    for (&invaders, 0..) |*row, i| {
        for (row, 0..) |*invader, j| {
            const x = invaderStartX + @as(f32, @floatFromInt(j)) * invaderSpacingX;
            const y = invaderStartY + @as(f32, @floatFromInt(i)) * invaderSpacingY;
            invader.* = Invader.init(x, y, invaderWidth, invaderHeight);
        }
    }
    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        if (game_over) {
            rl.drawText("GAME OVER", 270, 250, 40, rl.Color.red);

            const score_final = rl.textFormat("Score: %d", .{score});
            rl.drawText(score_final, 285, 310, 30, rl.Color.white);
            rl.drawText("Press Enter to play again or Esc to quit", 185, 360, 30, rl.Color.green);

            if (rl.isKeyPressed(rl.KeyboardKey.enter)) {
                game_over = false;
                resetGame(
                    &player,
                    &bullets,
                    &enemy_bullets,
                    &shields,
                    &invaders,
                    &invader_direction,
                    &score,
                    config,
                );
            }
            continue;
        }
        if (game_won) {
            rl.drawText("GAME WON !", 320, 250, 40, rl.Color.gold);

            const score_final = rl.textFormat("Score: %d", .{score});
            rl.drawText(score_final, 285, 310, 30, rl.Color.white);
            rl.drawText("Press Enter to play again or Esc to quit", 185, 360, 30, rl.Color.green);

            if (rl.isKeyPressed(rl.KeyboardKey.enter)) {
                game_over = false;
                resetGame(
                    &player,
                    &bullets,
                    &enemy_bullets,
                    &shields,
                    &invaders,
                    &invader_direction,
                    &score,
                    config,
                );
            }
            continue;
        }
        // UPDATE
        player.update();
        if (rl.isKeyPressed(rl.KeyboardKey.space) or rl.isKeyPressed(rl.KeyboardKey.k)) {
            for (&bullets) |*bullet| {
                if (!bullet.active) {
                    bullet.position_x = player.position_x + (player.width - bullet.width) / 2;
                    bullet.position_y = player.position_y;
                    bullet.active = true;
                    break;
                }
            }
        }

        for (&bullets) |*bullet| {
            bullet.update();
        }

        for (&enemy_bullets) |*bullet| {
            bullet.update(screenHeight);
            if (bullet.active) {
                if (bullet.getRect().intersect(player.getRect())) {
                    bullet.active = false;
                    game_over = true;
                }

                for (&shields) |*shield| {
                    if (shield.health > 0) {
                        if (bullet.getRect().intersect(shield.getRect())) {
                            bullet.active = false;
                            shield.health -= 1;
                            break;
                        }
                    }
                }
            }
        }

        enemy_shoot_timer += 1;
        if (enemy_shoot_timer >= enemyShootDelay) {
            enemy_shoot_timer = 0;
            for (&invaders) |*row| {
                for (row) |*invader| {
                    if (invader.isalive and rl.getRandomValue(0, 100) < enemyShootChance) {
                        for (&enemy_bullets) |*bullet| {
                            if (!bullet.active) {
                                bullet.position_x = (invader.position_x + invader.width - bullet.width) / 2;
                                bullet.position_y = invader.position_y + invader.height;
                                bullet.active = true;
                                break;
                            }
                        }
                        break;
                    }
                }
            }
        }

        // colisions
        for (&bullets) |*bullet| {
            if (bullet.active) {
                for (&invaders) |*row| {
                    for (row) |*invader| {
                        if (invader.isalive) {
                            if (bullet.getRect().intersect(invader.getRect())) {
                                bullet.active = false;
                                invader.isalive = false;
                                score += 10;
                                break;
                            }
                        }
                    }
                }

                for (&shields) |*shield| {
                    if (shield.health > 0) {
                        if (shield.getRect().intersect(bullet.getRect())) {
                            bullet.active = false;
                            shield.health -= 1;
                            break;
                        }
                    }
                }
            }
        }

        move_timer += 1;
        if (move_timer >= invaderMoveDelay) {
            move_timer = 0;

            var hit_edge = false;
            for (&invaders) |*row| {
                for (row) |*invader| {
                    if (invader.isalive) {
                        const next_x = invader.position_x + (invaderSpeed * invader_direction);
                        if (next_x < 0 or (next_x + invaderWidth) > @as(f32, @floatFromInt(screenWidth))) {
                            hit_edge = true;
                            break;
                        }
                    }
                }
                if (hit_edge) break;
            }
            if (hit_edge) {
                invader_direction *= -1.0;
                for (&invaders) |*row| {
                    for (row) |*invader| {
                        invader.update(0, invaderDropDistance);
                    }
                }
            } else {
                for (&invaders) |*row| {
                    for (row) |*invader| {
                        invader.update(invaderSpeed * invader_direction, 0);
                    }
                }
            }
            for (&invaders) |*row| {
                for (row) |*invader| {
                    if (invader.isalive) {
                        if (invader.getRect().intersect(player.getRect())) {
                            game_over = true;
                            break;
                        }
                    }
                }
            }
        }

        // Game won ?
        var all_invaders_dead = true;
        invader_alive: for (&invaders) |*row| {
            for (row) |*invader| {
                if (invader.isalive) {
                    all_invaders_dead = false;
                    break :invader_alive;
                }
            }
            // if (!all_invaders_dead) break; //break early
            // no more needed withe the named outer loop invader_alive
        }

        if (all_invaders_dead) {
            game_won = true;
        }

        // DRAW

        for (&shields) |*shield| {
            shield.draw();
        }

        player.draw();

        for (&bullets) |*bullet| {
            bullet.draw();
        }
        for (&invaders) |*row| {
            for (row) |*invader| {
                invader.draw();
            }
        }
        for (&enemy_bullets) |*bullet| {
            bullet.draw();
        }
        const score_text = rl.textFormat("Score: %d", .{score});

        rl.drawText(score_text, 20, screenHeight - 20, 20, rl.Color.white);
        //rl.drawText("Zig Invaders", 300, 200, 64, rl.Color.green);
        rl.drawText("Esc to quit, Space or k to shoot, <-/j and ->/l to move", 20, 20, 20, rl.Color.white);
    }

    return;
}
