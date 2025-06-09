module ExploreTheCorners
using Toolips
using Toolips.Components
using ToolipsSession

abstract type AbstractLocation end

mutable struct SubLocations <: AbstractLocation

end

approx_offset = (165, 175)

mutable struct Location <: AbstractLocation
    name::String
    position::Tuple{Int64, Int64}
    cover::String
    description::Component{:div}
end

locations = Vector{Location}()

for dir_file in readdir("public/locations")
    if dir_file == "backgrounds"
        continue
    end
    full_path::String = "public/locations/" * dir_file
    if isfile(full_path)
        continue
    end
    name_splits = split(dir_file, "SEP")
    cover = ""
    if isfile(full_path * "/cover.jpg")
        cover = "locations/$dir_file" * "/cover.jpg"
    end
    descmd = div("null")
    if isfile(full_path * "/description.md")
        descmd = Components.tmd("description", read(full_path * "/description.md", String))
    end
    dim = (parse(Int64, name_splits[2]), parse(Int64, name_splits[3]))
    push!(locations, 
        Location(string(replace(name_splits[1], "-" => " ")), dim,
        cover, descmd))
end

#==
extensions
==#
logger = Toolips.Logger()
SESSION = ToolipsSession.Session()
default_404 = Toolips.default_404

#==
routes
==#
stylesheet = begin
    hover_circs = Style("circle.hovercirc", "transition" => 800ms)
    hover_slide = keyframes("hoverslide")
    keyframes!(hover_slide, 0percent, "left" => 100percent)
    keyframes!(hover_slide, 100percent, "left" => 78percent)
    hover_label = Style("div.hoverlabel", "padding" => 1percent, "background-color" => "#333d33", "color" => "white", 
    "font-weight" => "bold", "font-size" => 15pt, "position" => "fixed", "border-radius" => 4px, "border" => "1px solid #1e1e1e", 
    "transition" => 850ms, "width" => 20percent, "height" => 30percent, "animation-name" => "hoverslide", "animation-duration" => 800ms,
    "height" => 100percent, "left" => 78percent, "top" => 0percent, "opacity" => 90percent)
    grow_forever = keyframes("growforever")
    keyframes!(grow_forever, 0percent, "transform" => scale(1))
    keyframes!(grow_forever, 100percent, "transform" => scale(1.5))
    bg_img = Style("img.bg", "animation-name" => "growforever", "animation-duration" => 120seconds, "transition" => 2seconds)
    fade_down = keyframes("fadedown")
    men_item = style("div.menuitem", "background-color" => "#262525", "padding" => 5percent, "border" => "2px solid #9c9c9c", "transition" => 2seconds, 
    "color" => "whitesmoke", "font-weight" => "bold", "font-size" => 17pt, "cursor" => "pointer", "user-select" => "none")
    men_item:"hover":["transform" => scale(1.1), "border" => "4px solid #e37c4f"]
    keyframes!(fade_down, 0percent, "transform" => translateY(-10percent), "opacity" => 0percent)
    keyframes!(fade_down, 100percent, "transform" => translateY(0percent), "opacity" => 100percent)
    fade_up = keyframes("fadeup")
    keyframes!(fade_up, 0percent, "transform" => translateY(10percent), "opacity" => 0percent)
    keyframes!(fade_up, 100percent, "transform" => translateY(0percent), "opacity" => 100percent)
    img_up = style("img.up", "position" => "absolute", "animation-name" => "fadedown", "animation-duration" => 1seconds)
    closer = style("div.closerbutt", "background-color" => "#b03751", "color" => "white", "cursor" => "pointer", "padding" => 1percent, 
    "animation-name" => "fadedown", "position" => "absolute", "width" => 2percent, "border-radius" => 4px, "left" => 97percent, "top" => .5percent, 
    "z-index" => 30, "animation-duration" => 1seconds, "animation-delay" => 1seconds, "font-weight" => "bold")
    Component{:sheet}("stylesheet", children = [hover_circs, hover_label, grow_forever, bg_img, fade_down, img_up, hover_slide, men_item, fade_up, closer])
end

function make_closebutton()
    butt = div("closer", text = "X", class = "closerbutt")
    style!(butt, "opacity" => 0percent)
    on(butt, "animationend") do cl
        style!(cl, "closer", "opacity" => 100percent)
    end
    butt
end

menu_box = begin
    men_pairs = ("flora" => "/images/icons/menu/plants.png", "fauna" => "/images/icons/menu/animals.png", "entomofauna" => "/images/icons/menu/bugs.png", 
    "geology" => "/images/icons/menu/geology.png", "anthropology" => "/images/icons/menu/anthro.png", 
    "archaeology" => "/images/icons/menu/arche.png", "about" => "/images/icons/menu/about.png")
    mens = [begin 
        name, url = menpair[1], menpair[2]
        new_men = div("$(name)men", class = "menuitem", align = "center", 
        children = [img(src = url, width = 50)])
        on(new_men, "mouseenter") do cl::ClientModifier
            set_text!(cl, new_men, name)
        end
        on(new_men, "mouseleave") do cl::ClientModifier
            set_children!(cl, new_men, [img(src = url, width = 50)])
        end
        new_men
    end for menpair in men_pairs]
    men_box = div("menubox", children = mens)
    style!(men_box, "position" => "absolute", "width" => 40percent, "left" => 30percent, "top" => 20percent, "grid-template-columns" => "1fr 1fr 1fr 1fr", 
    "display" => "grid", "animation-name" => "fadeup", "animation-duration" => 850ms, "z-index" => 19, "background" => "transparent")
    men_box
end

on(SESSION, "menopen") do cm::ComponentModifier
    if ~("menubox" in cm)
        image_header = img("exploreicon", src = "/images/logos/corners_icon.png", class = "up", width = 6percent)
        style!(image_header, "left" => 49percent, "top" => 1percent, "z-index" => 20, "animation-delay" => 1100ms, "opacity" => 0percent)
        on(image_header, "animationend") do cl::ClientModifier
            style!(cl, "exploreicon", "opacity" => 100percent)
        end
        style!(cm, "menu", "width" => 100percent, "opacity" => 88percent, "padding" => 10percent, "pointer-events" => "auto")
        append!(cm, "main", image_header)
        style!(cm, "head", "opacity" => 0percent)
        style!(cm, "mainsvgcont", "opacity" => 0percent)
        append!(cm, "main", menu_box)
        closer = make_closebutton()
        on("menopen", closer, "click")
        append!(cm, "main", closer)
        cm["menu"] = "expanded" => "1"
        return
    end
    style!(cm, "menu", "width" => 100percent, "opacity" => 0percent, "padding" => 0percent, 
    "pointer-events" => "none")
    if "exploreicon" in cm
        remove!(cm, "exploreicon")
    end
    remove!(cm, "menubox")
    remove!(cm, "closer")
    style!(cm, "head", "opacity" => 100percent)
    style!(cm, "mainsvgcont", "opacity" => 100percent)
end

main_menu = begin
    men = div("menu", expanded = 0)
    style!(men, "position" => "fixed", "width" => 0percent, "height" => 100percent, "left" => 0percent, "opacity" => 0percent, 
    "background-color" => "#2e2e2e", "transition" => 1seconds, "z-index" => 14, "top" => 0percent, "display" => "grid", "grid-templat-columns" => "5% 1fr 2fr")
    men
end

top_header = begin
    image = img("header", src = "/images/logos/corners_full_transw.png", width = 150px)
    style!(image, "user-select" => "none", "-webkit-user-select" => "none", "pointer-events" => "none", "transition" => 600ms)
    cont = div("head", align = "center", children = [image])
    on("menopen", cont, "click")
    on(cont, "mouseenter") do cl::ClientModifier
        style!(cl, image, "transform" => scale(1.1))
        cl[image] = "src" => "/images/logos/explore_the_corners_anim.gif"
    end
    on(cont, "mouseleave") do cl::ClientModifier
        style!(cl, image, "transform" => scale(1))
        cl[image] = "src" => "/images/logos/corners_full_transw.png"
    end
    style!(cont, "padding" => .5percent, "background-color" => "#2e2e2e", "border-bottom-right-radius" => 5px,
    "border-top-right-radius" => 5px, "cursor" => "pointer", "z-index" => 5,
    "border" => "2px solid #1e1e1e", "position" => "fixed", "top" => 1percent, "left" => 0percent, "user-select" => "none", "-webkit-user-select" => "none", 
    "opacity" => 100percent, "transition" => 800ms)
    cont
end

image_options = readdir("public/locations/backgrounds")

main = route("/") do c::Toolips.AbstractConnection
    write!(c, stylesheet)
    main_curs = Components.cursor("maincurs")
    main_svg = svg(width = 1000pt, height = 100percent, text = read("public/images/maps/corners.svg", String))
    style!(main_svg, "overflow" => "scroll")
    for location in locations
        safename = replace(location.name, " " => "")
        circ = Component{:circle}("$safename", class = "hovercirc", r = 10, cx = location.position[1] + approx_offset[1], cy = location.position[2] + approx_offset[2])
        on(c, circ, "mouseenter") do cm::ComponentModifier
            cm[circ] = "r" => 30
            style!(cm, circ, "fill" => "green")
            if ~("$safename-label"  in cm)
                new_label = div("$safename-label", class = "hoverlabel", close = "1")
                push!(new_label, h2(text = location.name))
                if location.cover != ""
                    cover = img(src = location.cover, width = 400, align = "center")
                    style!(cover, "width" => 100percent, "border-radius" => 6px)
                    push!(new_label, cover)
                end
                if location.description.name != "null"
                    push!(new_label, location.description)
                end
                append!(cm, "main", new_label)
            end
        end
        on(c, circ, "mouseleave") do cm::ComponentModifier
            cm[circ] = "r" => 10
            style!(cm, circ, "fill" => "#264594")
            if "$safename-label" in cm
                if cm["$safename-label"]["close"] == "0"
                    return
                end
                remove!(cm, "$safename-label")
            end
        end
        on(c, circ, "click") do cm::ComponentModifier
            if ~("$safename-label" in cm)
                return
            end
            cm["$safename-label"] = "close" => "0"
            cm["$safename-label"] = "align" => "center"
            style!(cm, "$safename-label", "left" => 0percent, "width" => 100percent, "top" => 0percent)
            next!(c, cm, circ) do cm2::ComponentModifier
                style!(cm2, "$safename-label", "height" => 100percent)
            end
        end
        style!(circ, "fill" => "#264594", "cursor" => "pointer")
        main_svg[:text] = main_svg[:text] * string(circ)
    end
    main_svg_container = div("mainsvgcont", align = "center", children = [main_svg])
    style!(main_svg_container, "overflow" => "show", "max-width" => 100percent, "max-height" => 85percent, 
    "opacity" => 100percent, "transition" => 900ms)
    init_bg = "/locations/backgrounds/" * ExploreTheCorners.image_options[rand(1:length(image_options))]
    bg  = img("bg-img", src = init_bg, class = "bg")
    style!(bg, "width" => 100percent, "max-height" => 100percent, "position" => "fixed", "left" => 0percent, "top" => 0percent, 
    "z-index" => -5, "opacity" => 100percent)
    bg_img_div = div("bgdiv", children = [bg], "z-index" => -6, inanim = "0")
    style!(bg_img_div, "transition" => 2seconds)
    on(c, 14000, recurring = true) do cm::ComponentModifier
        if cm[bg_img_div]["inanim"] == "1"
            return
        end
        cm[bg_img_div] = "inanim" => "1"
        style!(cm, "bg-img", "opacity" => 0percent, "z-index" => -6)
        on(c, cm, 2500) do cm2::ComponentModifier
            cm2[bg_img_div] = "inanim" => "0"
            cm2["bg-img"] = "class" => "null"
            cm2["bg-img"] = "class" => "bg"
            cm2["bg-img"] = "src" => "/locations/backgrounds/" * ExploreTheCorners.image_options[rand(1:length(image_options))]
            style!(cm2, "bg-img", "opacity" => 100percent, "z-index" => -6)
        end
    end
    main_bod = body("main", children = [bg_img_div, main_curs, main_menu, top_header, main_svg_container])
    style!(main_bod, "background-color" => "#0f0f0f", "overflow-x" => "visible")
    write!(c, main_bod)
end

public_files = mount("/" => "public")


abstract type AbstractCustomRoute <: Toolips.AbstractHTTPRoute end

mutable struct CustomRoute <: AbstractCustomRoute
    path::String
    page::Function
end
                        
route!(c::AbstractConnection, routes::Routes{AbstractCustomRoute}) = begin
    target = get_target(c)
    if contains(target, "@")
        write!(c, File("user_html/@sampleuser.html"))
    end
end


# make sure to export!
export start!, main, default_404, logger, public_files, SESSION
end # - module ExploreTheCorners <3