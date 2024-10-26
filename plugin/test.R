library(ggplot2)
data(iris)
ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
  geom_point()+theme_bw()+
  labs(title = "Sepal Length vs Sepal Width", x = "Sepal Length", y = "Sepal Width")
  plot.new()

ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
  geom_point()+theme_bw()+
  labs(title = "Sepal Length vs Sepal Width", x = "Sepal Length", y = "Sepal Width")
  quartz()

ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
  geom_point()
