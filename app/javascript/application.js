// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import jquery from "jquery"
window.$ = jquery
import { myFunction } from "./my_module";
import "custom/fadenotification";
document.addEventListener("DOMContentLoaded", () => {
    myFunction();
});