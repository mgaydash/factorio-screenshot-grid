from PIL import Image

# Size of the image grid captured
x = 15
y = 15

images = list(map(Image.open, ['script_output/image_'+str(j)+'_'+str(i)+'.png'
                               for j in range(y)
                               for i in range(x)
                               ]
                  )
              )

width, height = images[0].size
full_width = x * width
full_height = y * height

full_image = Image.new('RGB', (full_width, full_height))

images.reverse()

for j in range(y):
    for i in range(x):
        full_image.paste(images.pop(), (i * width, j * height))

full_image.save('full_map.jpg')
