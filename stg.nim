import nimraylib_now

const PLAYER_SIZE = 10

var screenWidth = 450
var screenHeight = 800

initWindow(screenWidth, screenHeight, "stgが基本でしょ")

# プレイヤー位置情報
var ownX = screenWidth.float/2.0
var ownY = screenHeight.float/2.0

# プレイヤーのたま
const MAX_TAMA_NUM = 100
const TAMA_SIZE_W = 5
const TAMA_SIZE_H = 10
var shotTamaIndex = 0
var tamaWait = 0
type TAMA = object
    x: int
    y: int
    display: bool
var tamas: seq[TAMA]
for i in 0..<MAX_TAMA_NUM:
    var tama: TAMA
    tama.display = false
    tamas.add(tama)

# 敵
const ENEMY_NUM = 30
type ENEMY = object
    x: int
    y: int
    hp: int
var enemies: seq[ENEMY]
for i in 0..<ENEMY_NUM:
    var enemy: ENEMY
    enemy.hp = getRandomValue(10, 30)
    enemy.x = getRandomValue(enemy.hp, screenWidth.int - enemy.hp)
    enemy.y = getRandomValue(-enemy.hp * 200, -enemy.hp)
    enemies.add(enemy)

# 出力FPSの設定
setTargetFPS(60)

# プレイ中
var isPlaying = false

# 死んだ
var die = false

while not windowShouldClose():
    if isPlaying == false:
        beginDrawing()
        clearBackground(Raywhite)
        drawText("Press [SPACE] to Start", (screenWidth.float/2.0).int - 100, (screenHeight.float/2.0).int, 10, Black)
        endDrawing()

        if isKeyDown(Space):
            isPlaying = true
        continue

    # 死んだ場合
    if die == true:
        beginDrawing()
        clearBackground(Raywhite)
        drawText("YOU LOOOOOOOSE", (screenWidth.float/2.0).int - 100, (screenHeight.float/2.0).int, 30, Red)
        endDrawing()
        continue

    # プレイヤーの移動処理
    if isKeyDown(KeyboardKey.Right):
        ownX += 5
        if (ownX + PLAYER_SIZE) >= screenWidth.float:
            ownX = screenWidth.float - PLAYER_SIZE
    if isKeyDown(KeyboardKey.Left):
        ownX -= 5
        if (ownX - PLAYER_SIZE) <= 0.float + PLAYER_SIZE:
            ownX = PLAYER_SIZE
    if isKeyDown(UP):
        ownY -= 5
        if (ownY - PLAYER_SIZE) <= 0 + PLAYER_SIZE:
            ownY = PLAYER_SIZE
    if isKeyDown(DOWN):
        ownY += 5
        if (ownY + PLAYER_SIZE) >= screenHeight.float:
            ownY = screenHeight.float - PLAYER_SIZE

    # 弾の射出
    if isKeyDown(Space):
        if tamaWait == 0:
            tamas[shotTamaIndex].x = ownX.int
            tamas[shotTamaIndex].y = ownY.int
            tamas[shotTamaIndex].display = true
            shotTamaIndex += 1
            if shotTamaIndex > MAX_TAMA_NUM - 1:
                shotTamaIndex = 0
            tamaWait = 5
        else:
            tamaWait -= 1

    # 当たり判定と敵HPの計算
    for e in 0..<ENEMY_NUM:
        for t in 0..<MAX_TAMA_NUM:
            if tamas[t].display == false:
                continue

            if ((enemies[e].x - enemies[e].hp) <= tamas[t].x and tamas[t].x <= (enemies[e].x + enemies[e].hp)) or (tamas[t].x <= (enemies[e].x - enemies[e].hp) and (enemies[e].x - enemies[e].hp) <= tamas[t].x + TAMA_SIZE_W):
                if ((enemies[e].y - enemies[e].hp) <= tamas[t].y and tamas[t].y <= (enemies[e].y + enemies[e].hp)) or (tamas[t].y <= (enemies[e].y - enemies[e].hp) and (enemies[e].y - enemies[e].hp) <= tamas[t].y + TAMA_SIZE_H):
                    enemies[e].hp = 0
                    if enemies[e].hp <= 0:
                        enemies[e].hp = 0
                        enemies[e].x = -10000
                    
                    tamas[t].display = false

    # 描画
    beginDrawing()
    # 背景をクリア
    clearBackground(Raywhite)

    # 自分を描く
    drawTriangle((ownX, ownY - PLAYER_SIZE).Vector2, (ownX - PLAYER_SIZE, ownY + PLAYER_SIZE).Vector2, (ownX + PLAYER_SIZE, ownY + PLAYER_SIZE).Vector2, ORANGE)
    # 弾を描く
    for i in 0..<MAX_TAMA_NUM:
        if not tamas[i].display:
            continue

        drawRectangle(tamas[i].x - (TAMA_SIZE_W / 2).int, tamas[i].y - TAMA_SIZE_H, TAMA_SIZE_W, TAMA_SIZE_H, ORANGE);

        tamas[i].y -= 5
        if tamas[i].y < -TAMA_SIZE_W:
            tamas[i].display = false

    # 敵を描く
    var liveEnemyNum = ENEMY_NUM
    for i in 0..<ENEMY_NUM:
        if enemies[i].hp <= 0:  # 死んだ敵は表示しない
            liveEnemyNum -= 1
            continue

        drawCircle(enemies[i].x, enemies[i].y, enemies[i].hp.float, RED); 
        enemies[i].y += 3

        if enemies[i].y > screenHeight + enemies[i].hp:
            die = true

    # スコア
    drawText("Enemies: " & $liveEnemyNum & " / " & $ENEMY_NUM, 5, 5, 5, Black)

    if liveEnemyNum <= 0:
        drawText("CLREA!", (screenWidth.float/2.0).int - 100, (screenHeight.float/2.0).int, 30, Red)

    endDrawing()
