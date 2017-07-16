library(clonevol)
data(aml1)
x <- aml1

# preparation: shorten vaf column names as they will be
# used as the sample names in all later visualizations
vaf.col.names <- grep('.vaf', colnames(x), value=T)
sample.names <- gsub('.vaf', '', vaf.col.names)
x[, sample.names] <- x[, vaf.col.names]
vaf.col.names <- sample.names
sample.groups <- c('P', 'R');
names(sample.groups) <- vaf.col.names
x <- x[order(x$cluster),]

clone.colors <- c('#999793', '#8d4891', '#f8e356', '#fe9536', '#d7352e')
#clone.colors <- NULL

pdf('box.pdf', width = 3, height = 5, useDingbats = FALSE, title='')
pp <- variant.box.plot(x,
       cluster.col.name = 'cluster',
       show.cluster.size = FALSE,
       cluster.size.text.color = 'blue',
       vaf.col.names = vaf.col.names,
       vaf.limits = 70,
       sample.title.size = 20,
       violin = FALSE,
       box = FALSE,
       jitter = TRUE,
       jitter.shape = 1,
       jitter.color = clone.colors,
       jitter.size = 3,
       jitter.alpha = 1,
       jitter.center.method = 'median',
       jitter.center.size = 1,
       jitter.center.color = 'darkgray',
       jitter.center.display.value = 'none',
       highlight = 'is.driver',
       highlight.note.col.name = 'gene',
       highlight.note.size = 2,
       highlight.shape =16,
       order.by.total.vaf = FALSE
)
dev.off()

y = infer.clonal.models(variants = x,
    cluster.col.name = 'cluster',
    vaf.col.names = vaf.col.names,
    sample.groups = sample.groups,
    cancer.initiation.model='monoclonal',
    subclonal.test = 'bootstrap',
    subclonal.test.model = 'non-parametric',
    num.boots = 1000,
    founding.cluster = '1',
    cluster.center = 'mean',
    ignore.clusters = NULL,
    clone.colors = clone.colors,
    min.cluster.vaf = 0.01,
    sum.p = 0.05,
    alpha = 0.05)

y <- transfer.events.to.consensus.trees(y,
    x[x$is.driver,],
    cluster.col.name = 'cluster',
    event.col.name = 'gene')

y <- convert.consensus.tree.clone.to.branch(y, branch.scale = 'sqrt')

plot.clonal.models(y,
   # box plot parameters
   box.plot = TRUE,
   fancy.boxplot = TRUE,
   fancy.variant.boxplot.highlight = 'is.driver',
   fancy.variant.boxplot.highlight.shape = 21,
   fancy.variant.boxplot.highlight.fill.color = 'red',
   fancy.variant.boxplot.highlight.color = 'black',
   fancy.variant.boxplot.highlight.note.col.name = 'gene',
   fancy.variant.boxplot.highlight.note.color = 'blue',
   fancy.variant.boxplot.highlight.note.size = 2,
   fancy.variant.boxplot.jitter.alpha = 1,
   fancy.variant.boxplot.jitter.center.color = 'grey50',
   fancy.variant.boxplot.base_size = 12,
   fancy.variant.boxplot.plot.margin = 1,
   fancy.variant.boxplot.vaf.suffix = '.VAF',
   # bell plot parameters
   clone.shape = 'bell',
   bell.event = TRUE,
   bell.event.label.color = 'blue',
   bell.event.label.angle = 60,
   clone.time.step.scale = 1,
   bell.curve.step = 2,
   # node-based consensus tree parameters
   merged.tree.plot = TRUE,
   tree.node.label.split.character = NULL,
   tree.node.shape = 'circle',
   tree.node.size = 30,
   tree.node.text.size = 0.5,
   merged.tree.node.size.scale = 1.25,
   merged.tree.node.text.size.scale = 2.5,
   merged.tree.cell.frac.ci = FALSE,
   # branch-based consensus tree parameters
   merged.tree.clone.as.branch = TRUE,
   mtcab.event.sep.char = ',',
   mtcab.branch.text.size = 1,
   mtcab.branch.width = 0.75,
   mtcab.node.size = 3,
   mtcab.node.label.size = 1,
   mtcab.node.text.size = 1.5,
   # cellular population parameters
   cell.plot = TRUE,
   num.cells = 100,
   cell.border.size = 0.25,
   cell.border.color = 'black',
   clone.grouping = 'horizontal',
   #meta-parameters
   scale.monoclonal.cell.frac = TRUE,
   show.score = FALSE,
   cell.frac.ci = TRUE,
   disable.cell.frac = FALSE,
   # output figure parameters
   out.dir = 'output',
   out.format = 'pdf',
   overwrite.output = TRUE,
   width = 8,
   height = 4,
   # vector of width scales for each panel from left to right
   panel.widths = c(3,4,1,3,1))

pdf('trees.pdf', width = 3, height = 5, useDingbats = FALSE)
plot.all.trees.clone.as.branch(y, branch.width = 0.5,
                               node.size = 1, node.label.size = 0.5)
dev.off()

plot.pairwise(x, col.names = vaf.col.names,
              out.prefix = 'variants.pairwise.plot',
              colors = clone.colors)


plot.cluster.flow(x, vaf.col.names =vaf.col.names,
                  sample.names = c('Primary', 'Relapse'),
                  out.file = 'flow.pdf',
                  colors = clone.colors)

