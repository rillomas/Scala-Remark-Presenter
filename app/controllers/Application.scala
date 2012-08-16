package controllers

import play.api._
import play.api.mvc._
import play.api.data._
import play.api.libs.json._
import play.api.data.Forms._
import models.Room
import models.Remark

object Application extends Controller {

  private val initialString = """
  　　　　_,,,,._　　　　　 　 　 　 　 　 　 ､-r
　 　,.','"￣｀,ゝ　_,,,_　　 _,,,_　　 _,,,,__,. | |　 _,,,,,_
　　{ {　　 ,___　,'r⌒!ﾞ! ,'r⌒!ﾞ! ,.'r⌒!.!"| l ,.'r_,,.>〉
　　ゝヽ､　~］|　ゞ_,.'ﾉ　ゞ_,.'ﾉ　ゞ__,.'ﾉ　| l {,ヽ､__,.
　　　｀ｰ-‐'"　　 ~　　　 ~　　〃 ｀ﾞ,ヽ￣｀ ｀ﾞ'''"
　　　　　　　　　　　　　　　　 ﾞ=､_,.〃
  """
 
  def index = Action { implicit request =>
    val uuid = java.util.UUID.randomUUID.toString
    Logger.info("Generated uuid: "+uuid)
    Ok(views.html.index("Remark Presenter", uuid, initialString))
  }

  def connect(userID: String) = WebSocket.async[JsValue] { request  =>
    Logger.info("userID from client: "+userID)
    Room.join(userID) 
  }
}


