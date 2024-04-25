import { Application } from "@hotwired/stimulus";
import Chartkick from "chartkick";
window.Chartkick = Chartkick;


const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
