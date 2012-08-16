package models

import akka.actor._
import akka.util.duration._

import play.api._
import play.api.libs.json._
import play.api.libs.iteratee._
import play.api.libs.concurrent._

import akka.util.Timeout
import akka.pattern.ask

import play.api.Play.current

object Room {

  lazy val default = Akka.system.actorOf(Props[Room])

  implicit val timeout = Timeout(1 second)

  def join(userID:String):Promise[(Iteratee[JsValue,_],Enumerator[JsValue])] = {
    (default ? Join(userID)).asPromise.map {
      
      case Connected(enumerator) => {
      
        // Create an Iteratee to consume the feed
        val iteratee = Iteratee.foreach[JsValue] { event =>
          val content = (event \ "Remark").as[String]
          val duration = (event \ "Duration").as[String]
          val path = (event \ "Path").as[String]
          val doRotate = (event \ "Rotate").as[Boolean]
          val remark = Remark(content, duration, path, doRotate)
          default ! Talk(userID, remark)
        }.mapDone { _ =>
          default ! Quit(userID)
        }

        (iteratee,enumerator)
      }
        
      case CannotConnect(error) => {
      
        // Connection error

        // A finished Iteratee sending EOF
        val iteratee = Done[JsValue,Unit]((),Input.EOF)

        // Send an error and close the socket
        val enumerator =  Enumerator[JsValue](JsObject(Seq("error" -> JsString(error)))).andThen(Enumerator.enumInput(Input.EOF))
        
        (iteratee,enumerator)
      }
    }
  }
}

case class Remark(content: String, duration: String, path: String, rotate: Boolean)
case class Join(userID: String)
case class Quit(userID: String)
case class Talk(userID: String, remark: Remark)

case class NotifyJoin(userID: String)
case class Connected(enumerator:Enumerator[JsValue])
case class CannotConnect(msg: String)

class Room extends Actor {
	private var clients = Map.empty[String, PushEnumerator[JsValue]]

	def receive = {
		case Join(userID) => {
      // Create an Enumerator to write to this socket
      val channel =  Enumerator.imperative[JsValue]( onStart = self ! NotifyJoin(userID))
      if(clients.contains(userID)) {
        sender ! CannotConnect("This userID is already used")
      } else {
        clients = clients + (userID -> channel)
        
        sender ! Connected(channel)
      }
		}

    case Quit(userID) => {
      clients = clients - userID
      Logger.info(userID + " leaved")
      //notifyAll("quit", userID, "has leaved the room")
    }

		case Talk(userID, remark) => {
      Logger.info(userID + ":" +remark.toString)
			// send to all clients
      val msg = Json.toJson(
          Map(
          "Remark" -> Json.toJson(remark.content),
          "Duration" -> Json.toJson(remark.duration),
          "Path" -> Json.toJson(remark.path),
          "Rotate" -> Json.toJson(remark.rotate)
        )
      ) 
      //Logger.info(msg.toString);
      clients.foreach { 
        case (_, channel) => channel.push(msg)
      }
  	}
    
    case NotifyJoin(userID) => {
      Logger.info(userID + " joined")
      // notifyAll("join", userID, "has entered the room")
    }
  }


  // def notifyAll(kind: String, user: String, text: String) {
  //   val msg = JsObject(
  //     Seq(
  //       "kind" -> JsString(kind),
  //       "user" -> JsString(user),
  //       "message" -> JsString(text),
  //       "clients" -> JsArray(
  //         clients.keySet.toList.map(JsString)
  //       )
  //     )
  //   )
    
  //   clients.foreach { 
  //     case (_, channel) => channel.push(msg)
  //   }
  // }
}