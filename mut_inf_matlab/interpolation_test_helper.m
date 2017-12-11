outputVideo = VideoWriter(fullfile('.','shuttle_out.avi'));
outputVideo.FrameRate = 24;
open(outputVideo)

for err_val = 0.0001:0.001:0.499
    err_val

[x_vals, y_vals] = meshgrid(0:0.001:0.5,0:0.001:1);
Ixy = FUN(x_vals, err_val, y_vals);
pcolor(Ixy);
shading interp;
colormap(jet(65536));
ylabel('t (edge independence). Information should increase -->');
xlabel('W (vertex independence). Information should decrease -->');

F = getframe(gcf);
[X, Map] = frame2im(F);

writeVideo(outputVideo,X)
   
end

close(outputVideo)