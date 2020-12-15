const express = require('express'); //如同Java import套件
const bodyParser = require('body-parser');
const cors = require('cors');
const app = express();
app.use(bodyParser.urlencoded({
    extended: true
}));
//而JavaScript中，所有的插件都是一個物件(沒有類別的概念，一導入就是實體，需要用變數接住)
const mysql = require('mysql'); //Import mysql套件
const {
    json
} = require('body-parser');
const port = process.env.PORT || 3000; //const是區域變數，不可改(類似java final)
//當專案產出、發佈到線上公開存取，這個數值會隨著不同的主機環境動態改變。所以這裡必須要設定一個動態的數值。
app.listen(port, () => {
    //在防火牆port監聽request
    console.log('Listening on port'); //在terminal中印出listening on port
});

//建立mysql連線
var conn = mysql.createConnection({
    host: '34.68.241.191', //資料庫在伺服器上，所以是填伺服器IP
    user: 'billy.wu', //輸入之前設定的使用者帳號
    password: 'billy.wu',
    database: 'ticketC',
});

// 建立連線後不論是否成功都會呼叫
conn.connect(function(err) {
    if (err) throw err;
    console.log('connect success!');
});

//其他的資料庫操作，位置預留

//關閉連線時呼叫
// conn.end(function(err) {
//     if (err) throw err;
//     console.log('connect end');
// })
app.use(cors());
// app.use(bodyParser.json());//允許接收json格式
// app.use(bodyParser.urlencoded({extended: true}));//允許接收x-www-form-urlencoded格式

var jsonParser = bodyParser.json(); //這個是區域的做法，只在特定api的路徑中指定接收型態
//var urlencodedParser = bodyParser.urlencoded({ extended: false });
//parse application/x-www-form-urlencoded，extended: false代表不允許接收巢狀資料

//創一個命名為api的路徑，開放接收get request的API
app.get('/api', (req, res, next) => {
    //req(request)別人給的參數，res(response)回傳給別人的參數
    res.send('test'); //response 'test'
});

//創一個命名為api2的路徑，開放接收get request的API
app.get('/api2', (req, res, next) => {
    res.json('testtest'); //用json格式response 'testtest'
});

app.post('/api3', jsonParser, (req, res) => {
    var name = req.body.name; //var是全域變數
    var image_id = req.body.image_id;

    let product = { //let是區域變數，可改
        name: name,
        image_id: image_id
    }
    res.json(product);
});

app.post('/getQuota', (req, res) => {
    let user = req.body.user
    conn.query('SELECT quota FROM users WHERE name = "' + user + '" LIMIT 1;', function(err, result, fields) {
        if (err) throw err;
        console.log(result);
        res.json(result);
    })
});

app.post('/getTickets', (req, res) => {
    let user = req.body.user
    let gotQuota
    conn.query('SELECT quota FROM users WHERE name = "' + user + '" LIMIT 1;', function(err, result, fields) {
        if (err) throw err;
        gotQuota = result[0].quota

        conn.query('SELECT * FROM tickets WHERE user_id IN (SELECT id from users WHERE name = "' + user + '") ORDER BY create_at;', function(err, result, fields) {
            if (err) throw err;
            let gotTickets = [];
            for (let i = 0; i < result.length; i++) {
                let arr = [];
                arr = {
                    id: result[i].id,
                    content: result[i].content,
                    create_at: result[i].create_at,
                    checked: result[i].checked,
                    deleted: result[i].deleted
                }
                gotTickets.push(arr);
            }
            let data = {
                quota: gotQuota,
                tickets: gotTickets
            }
            console.log(data);
            res.json(data);
        })
    })

});

app.post('/postNewTicket', jsonParser, (req, res) => {
    let ticketName = req.body.ticketName;
    let user = req.body.user
    console.log("new ticket:", ticketName);
    conn.query(`INSERT INTO tickets (user_id, content) VALUES ((SELECT id FROM users WHERE name = "` + user + `") , "` + ticketName + `");`, function(err, result, fields) {
        if (err) throw err;
        conn.query(`SELECT * FROM tickets WHERE id = (SELECT LAST_INSERT_ID());`, function(err, result, fields) {
            if (err) throw err;
            console.log(result);
            res.json(result);
        })
    })
});

app.post('/checkTicket', jsonParser, (req, res) => {
    let id = req.body.id; //var是全域變數
    console.log("test", id)
    conn.query(`UPDATE tickets SET checked = true WHERE id = ` + id, function(err, result, fields) {
        if (err) throw err;
        conn.query(`SELECT * FROM tickets WHERE id = ` + id + `;`, function(err, result, fields) {
            if (err) throw err;
            console.log(result);
            res.json(result);
        })
    })
});

app.post('/deleteTicket', jsonParser, (req, res) => {
    var id = req.body.id; //var是全域變數
    conn.query(`UPDATE tickets SET deleted = true WHERE id = ` + id, function(err, result, fields) {
        if (err) throw err;
        conn.query(`SELECT * FROM tickets WHERE id = ` + id + `;`, function(err, result, fields) {
            if (err) throw err;
            console.log(result);
            res.json(result);
        })
    })
});

app.get('/getInfoText', (req, res) => {
    conn.query('SELECT body, create_at FROM articles WHERE title = "info";', function(err, result, fields) {
        if (err) throw err;
        console.log(result);
        res.json(result);
    })
});

app.get('/getBirthdayLetter', (req, res) => {
    conn.query('SELECT header, body, footer, create_at FROM articles WHERE title = "birthdayLetter";', function(err, result, fields) {
        if (err) throw err;
        console.log(result);
        res.json(result);
    })
});

app.get('/renewAutoIncrement', jsonParser, (req, res) => {
    conn.query(`SELECT * FROM tickets;`, (err, result) => {
        if (err) {
            throw err;
        }
        for (let i = 0; i < result.length; i++) {
            conn.query(`SELECT * FROM tickets LIMIT 1 OFFSET ${i};`, (err, result1) => {
                if (err) {
                    throw err;
                }
                conn.query(`UPDATE tickets SET id = ${i} WHERE id = ${result[i].id};`, (err, result2) => {
                    if (err) {
                        throw err;
                    }
                })
            })
        }
    })
})