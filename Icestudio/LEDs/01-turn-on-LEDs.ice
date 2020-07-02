{
  "version": "1.2",
  "package": {
    "name": "",
    "version": "",
    "description": "",
    "author": "",
    "image": ""
  },
  "design": {
    "board": "go-board",
    "graph": {
      "blocks": [
        {
          "id": "07de1efa-e74a-472f-b629-25653b7e8fdb",
          "type": "basic.output",
          "data": {
            "name": "",
            "pins": [
              {
                "index": "0",
                "name": "LED1",
                "value": "56"
              }
            ],
            "virtual": false
          },
          "position": {
            "x": 1008,
            "y": 256
          }
        },
        {
          "id": "e20f5493-8fbb-4604-8993-0d580d7fcc88",
          "type": "basic.output",
          "data": {
            "name": "",
            "pins": [
              {
                "index": "0",
                "name": "LED2",
                "value": "57"
              }
            ],
            "virtual": false
          },
          "position": {
            "x": 1008,
            "y": 352
          }
        },
        {
          "id": "40207ce8-760a-497e-b5b4-49202be128db",
          "type": "basic.output",
          "data": {
            "name": "",
            "pins": [
              {
                "index": "0",
                "name": "LED3",
                "value": "59"
              }
            ],
            "virtual": false
          },
          "position": {
            "x": 1008,
            "y": 448
          }
        },
        {
          "id": "24d3f599-0398-497e-a2af-fc996f3007c9",
          "type": "basic.output",
          "data": {
            "name": "",
            "pins": [
              {
                "index": "0",
                "name": "LED4",
                "value": "60"
              }
            ],
            "virtual": false
          },
          "position": {
            "x": 1008,
            "y": 536
          }
        },
        {
          "id": "58b8f1f8-2aaa-4647-aa8c-54fd74fd62d4",
          "type": "725b7e2cb9666b5ed3183537d9c898f096dab82a",
          "position": {
            "x": 736,
            "y": 256
          },
          "size": {
            "width": 96,
            "height": 64
          }
        },
        {
          "id": "30880141-4930-42a4-9890-ff389f534241",
          "type": "725b7e2cb9666b5ed3183537d9c898f096dab82a",
          "position": {
            "x": 736,
            "y": 352
          },
          "size": {
            "width": 96,
            "height": 64
          }
        },
        {
          "id": "aa2f8390-c5ac-4827-8590-2a1660582186",
          "type": "725b7e2cb9666b5ed3183537d9c898f096dab82a",
          "position": {
            "x": 736,
            "y": 448
          },
          "size": {
            "width": 96,
            "height": 64
          }
        },
        {
          "id": "543b798d-5ee0-4462-bc62-7a9794c17d59",
          "type": "725b7e2cb9666b5ed3183537d9c898f096dab82a",
          "position": {
            "x": 736,
            "y": 536
          },
          "size": {
            "width": 96,
            "height": 64
          }
        },
        {
          "id": "cdd0abf1-a9b1-4c74-aae5-3894d3fad492",
          "type": "basic.info",
          "data": {
            "info": "# Turn all the LEDs on",
            "readonly": true
          },
          "position": {
            "x": 696,
            "y": 80
          },
          "size": {
            "width": 432,
            "height": 48
          }
        },
        {
          "id": "5d0a021c-e7f4-42c1-846f-f2aceb85ff7e",
          "type": "basic.info",
          "data": {
            "info": "Constant bit 1",
            "readonly": true
          },
          "position": {
            "x": 744,
            "y": 216
          },
          "size": {
            "width": 144,
            "height": 32
          }
        },
        {
          "id": "27d14d8d-96d0-41ab-b4f4-d8df42213ccf",
          "type": "basic.info",
          "data": {
            "info": "wire",
            "readonly": true
          },
          "position": {
            "x": 896,
            "y": 248
          },
          "size": {
            "width": 72,
            "height": 32
          }
        },
        {
          "id": "cf011436-50ca-407e-ad29-742553fb0a42",
          "type": "basic.info",
          "data": {
            "info": "FPGA pin",
            "readonly": true
          },
          "position": {
            "x": 1024,
            "y": 232
          },
          "size": {
            "width": 96,
            "height": 32
          }
        }
      ],
      "wires": [
        {
          "source": {
            "block": "58b8f1f8-2aaa-4647-aa8c-54fd74fd62d4",
            "port": "3d584b0a-29eb-47af-8c43-c0822282ef05"
          },
          "target": {
            "block": "07de1efa-e74a-472f-b629-25653b7e8fdb",
            "port": "in"
          }
        },
        {
          "source": {
            "block": "30880141-4930-42a4-9890-ff389f534241",
            "port": "3d584b0a-29eb-47af-8c43-c0822282ef05"
          },
          "target": {
            "block": "e20f5493-8fbb-4604-8993-0d580d7fcc88",
            "port": "in"
          },
          "vertices": []
        },
        {
          "source": {
            "block": "aa2f8390-c5ac-4827-8590-2a1660582186",
            "port": "3d584b0a-29eb-47af-8c43-c0822282ef05"
          },
          "target": {
            "block": "40207ce8-760a-497e-b5b4-49202be128db",
            "port": "in"
          },
          "vertices": []
        },
        {
          "source": {
            "block": "543b798d-5ee0-4462-bc62-7a9794c17d59",
            "port": "3d584b0a-29eb-47af-8c43-c0822282ef05"
          },
          "target": {
            "block": "24d3f599-0398-497e-a2af-fc996f3007c9",
            "port": "in"
          },
          "vertices": []
        }
      ]
    }
  },
  "dependencies": {
    "725b7e2cb9666b5ed3183537d9c898f096dab82a": {
      "package": {
        "name": "1",
        "version": "0.1",
        "description": "Un bit constante a 1",
        "author": "Jesus Arroyo",
        "image": "%3Csvg%20xmlns=%22http://www.w3.org/2000/svg%22%20width=%2233.632%22%20height=%2269.34%22%20viewBox=%220%200%2031.530464%2065.006656%22%3E%3Cpath%20d=%22M3.517%2012.015L19%200l12.53%202.863-10.012%2043.262-9.746-2.227%207.7-34.532L8.03%2016.38z%22%20fill=%22green%22%20fill-rule=%22evenodd%22/%3E%3Cpath%20d=%22M17.593%2043.464l7.822%2010.472-6.56%207.919%202.27%202.043m-5.14-20.179l-4.542%2010.473-10.345%202.043.757%203.32%22%20fill=%22none%22%20stroke=%22green%22%20stroke-width=%222.196%22%20stroke-linecap=%22round%22%20stroke-linejoin=%22round%22/%3E%3C/svg%3E"
      },
      "design": {
        "graph": {
          "blocks": [
            {
              "id": "3d584b0a-29eb-47af-8c43-c0822282ef05",
              "type": "basic.output",
              "data": {
                "name": ""
              },
              "position": {
                "x": 512,
                "y": 160
              }
            },
            {
              "id": "61331ec5-2c56-4cdd-b607-e63b1502fa65",
              "type": "basic.code",
              "data": {
                "code": "//-- Bit constante a 1\nassign q = 1'b1;\n\n",
                "params": [],
                "ports": {
                  "in": [],
                  "out": [
                    {
                      "name": "q"
                    }
                  ]
                }
              },
              "position": {
                "x": 168,
                "y": 112
              },
              "size": {
                "width": 256,
                "height": 160
              }
            }
          ],
          "wires": [
            {
              "source": {
                "block": "61331ec5-2c56-4cdd-b607-e63b1502fa65",
                "port": "q"
              },
              "target": {
                "block": "3d584b0a-29eb-47af-8c43-c0822282ef05",
                "port": "in"
              }
            }
          ]
        }
      }
    }
  }
}