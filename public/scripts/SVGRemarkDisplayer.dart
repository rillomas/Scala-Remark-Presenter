#library("SVGRemarkDisplayer");
#import("dart:html");
#import("RemarkDisplayer.dart");

/**
  * Class representing a remark
  */
class Remark {
    Remark(this.node, this.parameter, this.isSelected);
    SVGElement node;
    DisplayParameter parameter;
    bool isSelected;
}

/**
 * Class that displays remarks via SVG
 */
class SVGRemarkDisplayer implements RemarkDisplayer {
    SVGRemarkDisplayer() {
        _remarkList = new List<Remark>();
        _currentRemark = 0;
        _numberOfRemarks = 0;
    }

    /**
     * Create remark nodes under the tag with the given ID
     */
    void initialize(String stageID, int numberOfRemarks) {
        _numberOfRemarks = numberOfRemarks;
        _setupStage(stageID, numberOfRemarks);
    }

    /**
     * Display given remark at the current node
     */
    void display(DisplayParameter parameter) {
        var remark = _remarkList[_currentRemark];

        // delete any nodes we already have
        remark.node.nodes.clear();

        // convert text to svg
        var lines = parameter.remark.split("\n");
        SVGTextElement text = new SVGElement.svg("<text font-family='IPA モナーPゴシック' y='100'></text>");
        for (int i=0; i<lines.length; i++) {
            var line = lines[i];
            SVGTSpanElement span = new SVGElement.svg("<tspan x='0' dy='15'>${line}</tspan>");
            text.nodes.add(span);
            //list.add(span);
        }
        
        remark.node.nodes.add(text);
        var duration = "${parameter.duration}${parameter.durationUnit.toString()}";
        SVGAnimateElement fade
            = new SVGElement.svg("<animate attributeName='opacity' from='1' to='0' dur='${duration}' begin='indefinite' fill='freeze' />");
        //SVGAnimationElement animation
        //     = new SVGElement.svg("<animateTransform attributeName='transform' type='translate' from='0' to='1300' dur='${duration}' fill='freeze' begin='indefinite' />");
        SVGAnimationElement path = null;
        if (parameter.rotate) {
            path = new SVGElement.svg("<animateMotion path='${parameter.path}' dur='${duration}' fill='freeze' begin='indefinite' rotate='auto' />");
        } else {
            path = new SVGElement.svg("<animateMotion path='${parameter.path}' dur='${duration}' fill='freeze' begin='indefinite' />");
        }
        remark.node.nodes.add(path);
        remark.node.nodes.add(fade);
        
        remark.node.on.mouseDown.add((MouseEvent e) {
                if (e.target is SVGElement) {
                    SVGElement elem = e.target;
                    print("left: ${elem.style.left} right: ${elem.style.top}");
                    print("mouse down!! x:${e.clientX} y:${e.clientY}");
                }
                print(e.srcElement);
                print(e.target);
                path.endElement();
                fade.endElement();
        });
        
        remark.node.on.dragStart.add((Event e) {
                print("drag start");
        });

        remark.node.on.mouseMove.add((MouseEvent e) {
                //print(e.button);
                //print(e.button);
                //if (e.button == 0) {
                // print("mouse drag!");
                //}
        });
        
        path.beginElement();
        fade.beginElement();

        // proceed to next remark
        _currentRemark++;
        if (_currentRemark >= _numberOfRemarks) {
            _currentRemark = 0;
        }
    }

    /**
      * Setup the stage for remarks
      */
    void _setupStage(String stageID, int numberOfRemarks) {
        Element stage = document.query(stageID);

        var svg = new SVGSVGElement();
        for (int i=0; i<numberOfRemarks; i++) {
            SVGGElement g = new SVGElement.svg("<g draggable='true'></g>");
            svg.nodes.add(g);

            var r = new Remark(g, null, false);
            _remarkList.add(r);
        }

        stage.nodes.add(svg);
    }

    int _numberOfRemarks;
    List<Remark> _remarkList;
    int _currentRemark;
}