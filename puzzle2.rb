require "gtk3"
require "thread"
require_relative "puzzle1"

# Definición de la clase principal Window que hereda de Gtk::Window
class Window < Gtk::Window
  def initialize
    super
    set_title 'rfid_gtk.rb' # Estableix el títol de la finestra
    set_border_width 10     # Defineix el marge de la finestra
    set_size_request 500, 200 # Tamany de la finestra

    # Conecta la senyal "destroy" de la finestra per a tancar  la aplicació 
    signal_connect("destroy") do
      Gtk.main_quit             # Surt del loop principal de GTK
      @thread.kill             # Atura el thread de lectura si está en execució
    end

    # Crea un contenedor vertical per organitzar els  widgets/funcionalitats dins de la finestra
    @hbox = Gtk::Box.new(:vertical, 6)
    add(@hbox)

    # Crea un Label que mostra el missatge de instruccions al usuari
    @label = Gtk::Label.new("Por favor, acerque su tarjeta al lector")
    @label.override_background_color(0, Gdk::RGBA.new(0, 0, 1, 1)) # Fons blau
    @label.override_color(0, Gdk::RGBA.new(1, 1, 1, 1))           # Text blanc
    @label.set_size_request(100, 200) # Tamany del label
    @hbox.pack_start(@label)          # Afegeix el Label al contenidor

    # Crea un botó de "Clear" para esborrar la informació del UID llegit
    @button = Gtk::Button.new(label: 'Clear')
    @button.signal_connect('clicked') { on_clear_clicked } # Asocia el event "clicked" amb el mètode on_clear_clicked
    @button.set_size_request(100, 50) # Tamany del botó
    @hbox.pack_start(@button)         # Afegeix el botó al contenidor
  end

  # Mètode per gestionar l'event depreionar el botó "Clear"
  def on_clear_clicked
    # Restaura el missatge inicial en el Label
    @label.set_markup("Por favor, acerque su tarjeta al lector")
    @label.override_background_color(0, Gdk::RGBA.new(0, 0, 1, 1)) # Canvia el fons a blau
    @thread.kill                 # Atura el thread de lectura si està executant
    rfid                         # Reinicia la lectura del UID
  end

  # Mètode para iniciar el procés de lectura de UID en un thread separat
  def rfid
    @rfid = Rfid.new               # Instancia l' objecte Rfid
    # Crea un nou thread  per a  realitzar la lectura del UID
    @thread = Thread.new do
      uid = @rfid.read_uid         # Llegeix l' UID desde el lector RFID
      # Actualitza la interface en el thread principal per evitar bloqueigs
      GLib::Idle.add do
        @label.set_markup("uid: " + uid) # Mostra l'UID llegit en el Label
        @label.override_background_color(0, Gdk::RGBA.new(1, 0, 0, 1)) # Canvia el fons a vermell
        false # Retorna false para asegurar que la actualizació s'executi tan  sols una cop
      end
    end
  end
end

# Crea y mostra una instància de la finestra principal
win = Window.new
win.show_all
win.rfid # Inicia el mètode de lectura RFID
Gtk.main # Inicia el loop principal de la interfazinteface gràfica
