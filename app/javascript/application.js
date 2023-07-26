// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import { myFunction } from "my_module";

document.addEventListener("DOMContentLoaded", () => {
    myFunction();
});