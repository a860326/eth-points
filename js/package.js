var web3 = new Web3();
var sessionStorage = window.sessionStorage;
var provider = sessionStorage.getItem("provider");
console.log("web3.provider:"+provider);
var account = sessionStorage.getItem("account");
console.log("account:"+account);
var abi = [
      {
        "constant": false,
        "inputs": [
          {
            "name": "mobileid",
            "type": "uint256"
          },
          {
            "name": "merid",
            "type": "uint256"
          },
          {
            "name": "points",
            "type": "uint256"
          }
        ],
        "name": "costpoints",
        "outputs": [
          {
            "name": "result",
            "type": "bool"
          }
        ],
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "mobileid",
            "type": "uint256"
          },
          {
            "name": "fmerid",
            "type": "uint256"
          },
          {
            "name": "fpoints",
            "type": "uint256"
          },
          {
            "name": "tmerid",
            "type": "uint256"
          },
          {
            "name": "tpoints",
            "type": "uint256"
          }
        ],
        "name": "issueTrans",
        "outputs": [
          {
            "name": "result",
            "type": "bool"
          }
        ],
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "mobileid",
            "type": "uint256"
          },
          {
            "name": "index",
            "type": "uint256"
          }
        ],
        "name": "subTrans",
        "outputs": [
          {
            "name": "result",
            "type": "bool"
          }
        ],
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [],
        "name": "getTransLength",
        "outputs": [
          {
            "name": "length",
            "type": "uint256"
          }
        ],
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "mobileid",
            "type": "uint256"
          },
          {
            "name": "index",
            "type": "uint256"
          }
        ],
        "name": "cancelTrans",
        "outputs": [
          {
            "name": "result",
            "type": "bool"
          }
        ],
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "index",
            "type": "uint256"
          }
        ],
        "name": "getTransinf",
        "outputs": [
          {
            "name": "fmobileid",
            "type": "uint256"
          },
          {
            "name": "fmerid",
            "type": "uint256"
          },
          {
            "name": "fpoints",
            "type": "uint256"
          },
          {
            "name": "tmerid",
            "type": "uint256"
          },
          {
            "name": "tpoints",
            "type": "uint256"
          },
          {
            "name": "tmobileid",
            "type": "uint256"
          },
          {
            "name": "state",
            "type": "uint256"
          },
          {
            "name": "transtime",
            "type": "uint256"
          },
          {
            "name": "intime",
            "type": "uint256"
          }
        ],
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "mobileid",
            "type": "uint256"
          },
          {
            "name": "merid",
            "type": "uint256"
          }
        ],
        "name": "queryPoints",
        "outputs": [
          {
            "name": "total",
            "type": "uint256"
          },
          {
            "name": "lock",
            "type": "uint256"
          },
          {
            "name": "useable",
            "type": "uint256"
          }
        ],
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "mobileid",
            "type": "uint256"
          },
          {
            "name": "merid",
            "type": "uint256"
          },
          {
            "name": "points",
            "type": "uint256"
          }
        ],
        "name": "earnpoints",
        "outputs": [
          {
            "name": "result",
            "type": "bool"
          }
        ],
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "mobileid",
            "type": "uint256"
          }
        ],
        "name": "register",
        "outputs": [
          {
            "name": "result",
            "type": "bool"
          }
        ],
        "type": "function"
      },
      {
        "inputs": [],
        "type": "constructor"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": false,
            "name": "_method",
            "type": "string"
          },
          {
            "indexed": false,
            "name": "_message",
            "type": "string"
          },
          {
            "indexed": false,
            "name": "_result",
            "type": "bool"
          }
        ],
        "name": "Log",
        "type": "event"
      }
    ];
//console.log("contract.abi:"+JSON.stringify(abi));

web3.setProvider(new web3.providers.HttpProvider(provider));
web3.eth.defaultAccount = account;
console.log("链接状态:"+web3.isConnected());

var sender = sessionStorage.getItem("sender");
console.log("msg.sender:"+sender);
var contract = web3.eth.contract(abi);
var Points = contract.at(sender);
//初始化数据
//sessionStorage.setItem("mobileid", 13800138000);

var mers = [1234, 1235, 1236];
var mername = ['联动', '腾讯', '阿里'];
