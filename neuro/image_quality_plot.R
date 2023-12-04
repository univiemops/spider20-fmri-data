library('ggplot2')



# import data
group_bold <- read.table('/Volumes/ExtrmSSD_2T/Spider2021/derivatives/mriqc/group_bold.tsv', header = TRUE)
sub <- rep(paste0('sub-', sprintf("%02d", c(3, 5:52))), each = 7)
run <- c(paste0('run-', 1:5), 'rest-post', 'rest-pre')
fd_bold <- group_bold[-c(1:14, 22:28), c(1, 10)] 
fd_bold <- cbind(sub, run, fd_bold)
tsnr_bold <-  group_bold[-c(1:14, 22:28), c(1, 45)] 
tsnr_bold <- cbind(sub, run, tsnr_bold)

# framewise displacement plot 
## by subjects
fd_bold_plot <- ggplot(data = fd_bold, aes(x = sub, y = fd_mean, group = sub))
fd_bold_plot + 
  geom_point(color = 'gray50') + 
  #geom_violin(color = 'gray', fill = 'gray') + 
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "gray") +
  stat_summary(fun = 'mean', 
               geom = 'point', 
               color = 'black', 
               size = 2.5) + 
  ylab('Framewise Displacement (mm)') +
  xlab('Subject ID') +
  theme_classic() +
  theme(axis.title.x = element_text(size = 13), 
        axis.title.y = element_text(size = 13), 
        axis.text.x = element_text(angle = 90, hjust = 0),
        axis.text.y = element_text(size = 10)) 

## by runs
fd_bold_plot <- ggplot(data = fd_bold, aes(x = factor(run, levels = c(c(paste0('run-', 1:5), 'rest-pre', 'rest-post'))), 
                                           y = fd_mean, group = run))
fd_bold_plot + 
  geom_violin(color = 'gray', fill = 'gray') + 
  geom_point(color = 'gray50', size = 4) + 
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "gray", size = 1.5) +
  stat_summary(fun = 'mean', geom = 'point', color = 'black', size = 6) + 
  stat_summary(fun = mean, geom = "text", aes(label = round(..y.., 3)), hjust = -0.3, size = 5) +
  ylab('Framewise Displacement (mm)') +
  xlab('Runs') +
  theme_classic() +
  theme(axis.title.x = element_text(size = 22), 
        axis.title.y = element_text(size = 22), 
        axis.text.x = element_text(size = 18),
        axis.text.y = element_text(size = 18)) 

# temporal signal to noise ratio plot 
## by subjects
tsnr_bold_plot <- ggplot(data = tsnr_bold, aes(x = sub, y = tsnr, group = sub))
tsnr_bold_plot + 
  geom_point(color = 'gray50') + 
  #geom_violin(color = 'gray', fill = 'gray') + 
  stat_summary(fun = 'mean', 
              geom = 'point', 
              color = 'black', 
              size = 2.5) + 
  ylab('tSNR') +
  xlab('Subject ID') +
  theme_classic() +
  theme(axis.title.x = element_text(size = 13), 
        axis.title.y = element_text(size = 13), 
        axis.text.x = element_text(angle = 90, hjust = 0),
        axis.text.y = element_text(size = 10)) 

## by runs
tsnr_bold_plot <- ggplot(data = tsnr_bold, aes(x = factor(run, levels = c(c(paste0('run-', 1:5), 'rest-pre', 'rest-post'))), 
                                               y = tsnr, group = run))
tsnr_bold_plot + 
  geom_violin(color = 'gray', fill = 'gray') + 
  geom_point(color = 'gray50', size = 4) + 
  stat_summary(fun = 'mean', geom = 'point', color = 'black', size = 6) + 
  stat_summary(fun = mean, geom = "text", aes(label = round(..y.., 3)), hjust = -0.3, size = 5) +
  ylab('tSNR') +
  xlab('Runs') +
  theme_classic() +
  theme(axis.title.x = element_text(size = 22), 
        axis.title.y = element_text(size = 22), 
        axis.text.x = element_text(size = 18),
        axis.text.y = element_text(size = 18)) 

