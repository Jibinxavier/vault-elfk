# from https://stackoverflow.com/questions/753190/programmatically-generate-video-or-animated-gif-in-python
import imageio
import glob 
images = []
for filename in sorted(glob.glob("images/*.png")):
    images.append(imageio.imread(filename))
imageio.mimsave('tes.gif', images, duration=1 )