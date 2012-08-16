#library("App");
#import("dart:html");
#import("dart:json");
#import("RemarkDisplayer.dart");
#import("SVGRemarkDisplayer.dart");
#import("Unit.dart");

class PanelLayoutParameter {
    PanelLayoutParameter(this.inputPanelID, this.displayAreaID, this.remarkPanelID, this.hideInputPanelID, this.hideRemarkPanelID);
    String inputPanelID;
    String displayAreaID;
    String remarkPanelID;
    String hideInputPanelID;
    String hideRemarkPanelID;
}

/**
  * Manages Panel Layout
  */
class PanelLayout {
    PanelLayout() {
        _inputPanelVisible = true;
        _remarkPanelVisible = true;
    }

    /**
      * Setup the side bar for setting
      */
    void initialize(PanelLayoutParameter param) {
        _inputPanel = document.query(param.inputPanelID);
        _displayArea = document.query(param.displayAreaID);
        _remarkPanel = document.query(param.remarkPanelID);
        _hideInputBtn = document.query(param.hideInputPanelID);       
        _hideInputBtn.on.click.add(_onPanelVisibilityChange);
    }

    /**
      * Change the panel layout
      */
    void _onPanelVisibilityChange(Event e) {
        // switch visibility of the setting area
        _inputPanelVisible = !_inputPanelVisible;
        if (_inputPanelVisible) {
            int displayAreaWidth = FULL_WIDTH - INPUT_PANEL_WIDTH;

            // expand setting area
            _inputPanel.style.visibility = "visible";
            _inputPanel.style.width = "";
            _inputPanel.classes = ["span${INPUT_PANEL_WIDTH}"];
            _displayArea.classes = ["offset${INPUT_PANEL_WIDTH}", "span${displayAreaWidth}"];
            _hideInputBtn.text = "Hide Input Panel";
        } else {
            int displayAreaWidth = FULL_WIDTH;

            // hide setting area and expand display area
            _inputPanel.style.visibility = "collapse";
            _inputPanel.classes = ["span"];
            _inputPanel.style.width = "0px";
            _displayArea.classes = ["span${displayAreaWidth}"];
            _hideInputBtn.text = "Show Input Panel";
        }
    }

    final int FULL_WIDTH = 12;
    final int INPUT_PANEL_WIDTH = 6;
    final int REMARK_PANEL_WIDTH = 2;
    bool _inputPanelVisible;
    bool _remarkPanelVisible;

    Element _inputPanel;
    Element _displayArea;
    Element _remarkPanel;
    Element _hideInputBtn;
}

class App {
    App() {
        _layout = new PanelLayout();
    }

    void initialize(String url, RemarkDisplayer displayer, PanelLayoutParameter layoutParam) {
        // create websocket and add handlers
        WebSocket webSocket = new WebSocket(url);
        Element status = document.query("#statusArea");
        webSocket.on.message.add((event) {
                // display remark with given parameters
                var message = event.data;
                print(message);
                Map<String, Object> map = JSON.parse(message);
                DisplayParameter param = new DisplayParameter.map(map);
                displayer.display(param);
            });
        
        // connect post button with websocket
        TextAreaElement textNode = document.query("#remarkText");
        TextAreaElement pathNode = document.query("#pathString");
        Element postButton = document.query("#postRemark");
        InputElement speedNode = document.query("#displaySpeed");
        InputElement rotateNode = document.query("#rotateRemark");
        postButton.on.click.add((Event e) {
                String message = textNode.value;
                String path = pathNode.value;
                
                bool rotate = rotateNode.checked;
                var num = speedNode.valueAsNumber;
                var duration = (MAX_SPEED - num.toInt()) * 100;
                var param = new DisplayParameter(message, duration, Unit.Millisecond, path, rotate);
                String paramJson = JSON.stringify(param.toMap());
                webSocket.send(paramJson);
            });

        _layout.initialize(layoutParam);
    }

    final int MAX_SPEED = 100;
    RemarkDisplayer _displayer;
    PanelLayout _layout;
}

