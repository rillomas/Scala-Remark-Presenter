#library("RemarkDisplayer");
#import("dart:html");
#import("Unit.dart");
/**
 * Parameter for displaying
 */
class DisplayParameter {
    DisplayParameter(this.remark, this.duration, this.durationUnit, this.path, this.rotate);

    DisplayParameter.map(Map<String, Object> map) {
        remark = map["Remark"];
        path = map["Path"];
        String durationStr = map["Duration"];
        List strList = durationStr.split(_separator);
        duration = Math.parseInt(strList[0]);
        durationUnit = new Unit(strList[1]);
        rotate = map["Rotate"];
    }

    String remark;
    int duration;
    Unit durationUnit;
    String path;
    bool rotate;

    Map<String, Object> toMap() {
        Map<String, Object> map = new Map<String, Object>();
        map["Remark"] = remark;
        map["Duration"] = "${duration}${_separator}${durationUnit.toString()}";
        map["Path"] = path;
        map["Rotate"] = rotate;
        return map;
    }

    final String _separator = "&";
}

/**
 * Class that manages remark display
 */
interface RemarkDisplayer {
    /**
     * Display given remark
     */
    void display(DisplayParameter param);
}
