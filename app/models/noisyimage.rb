require 'rubygems'  
require 'mini_magick'  
class NoisyImage  
				include MiniMagick  
				attr_reader:code,:image  
				Jiggle = 15
				Wobble = 15

				def initialize(len = 4)
								chars = ('a'..'z').to_a + ('0'..'9').to_a
								rand_chars = []
								1.upto(len) {rand_chars.push(chars[rand(chars.length)])}#生成验证码

								background_type ="granite:"#彩条"granite:"#花岗岩"xc:#EDF7E7"#指定背景色"null:"#纯黑
								background = Magick::ImageList.new(background_type) #背景画布

								canvas = Magick::ImageList.new #新建一个画布
								canvas.new_image(32*len, 30, Magick::TextureFill.new(background)) #把背景加到画布上

								gc = Magick::Draw.new #新建一个画笔
								gc.font_family = 'times'
								gc.pointsize = 20
								cur = 10
								rand_chars.each{|c|
												gc.annotate(canvas, 0, 0, cur, 15+rand(Jiggle), c){
																self.rotation = rand(10) > 5 ? rand(Wobble) : -rand(Wobble)
																self.font_weight = rand(10) > 5 ? NormalWeight : BoldWeight
																self.fill = 'black'
												}
												cur += 30
								}

								@code = rand_chars.to_s
								@image = canvas.to_blob{
												self.format="JPG"
								}
				end
end
