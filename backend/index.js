const express = require('express'); //如同Java import套件
const bodyParser = require('body-parser');
const cors = require('cors');
const app = express();
//而JavaScript中，所有的插件都是一個物件(沒有類別的概念，一導入就是實體，需要用變數接住)
const mysql = require('mysql'); //Import mysql套件
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

app.get('/getQuota', (req, res) => {
    conn.query('SELECT (quota) FROM settings LIMIT 1;', function(err, result, fields) {
            if (err) throw err;
            console.log(result);
            res.json(result);
        })
        // res.json(result);

    // });
});

app.get('/getTickets', (req, res) => {
    conn.query('SELECT * FROM tickets;', function(err, result, fields) {
        if (err) throw err;
        console.log(result);
        res.json(result);
    })
});

app.post('/postNewTicket', jsonParser, (req, res) => {
    var name = req.body.ticketName; //var是全域變數
    conn.query(`INSERT INTO tickets (content) VALUES ("` + name + `") ;`, function(err, result, fields) {
        if (err) throw err;
        console.log(result);
    })

    conn.query(`SELECT (id) FROM tickets WHERE content = "` + name + `" LIMIT 1;`, function(err, result, fields) {
        if (err) throw err;
        console.log(result);
        res.json(result);
    })
});